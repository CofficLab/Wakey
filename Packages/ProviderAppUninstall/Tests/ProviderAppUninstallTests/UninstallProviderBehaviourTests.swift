import Foundation
import Testing
@testable import ProviderAppUninstall

// MARK: - 测试替身

/// 记录被移除的持久化域，可选地抛出错误。
final class StubDomainRemover: UninstallPersistentDomainRemoving, @unchecked Sendable {
    private(set) var removedDomains: [String] = []
    var errorToThrow: Error?

    func removePersistentDomain(named name: String) throws {
        removedDomains.append(name)
        if let errorToThrow {
            throw errorToThrow
        }
    }
}

/// 记录被移除的 Keychain 服务。
final class StubKeychainManager: UninstallKeychainManaging, @unchecked Sendable {
    var existingServices: Set<String>
    private(set) var removedServices: [String] = []

    init(existingServices: Set<String> = []) {
        self.existingServices = existingServices
    }

    func containsItems(forService service: String) -> Bool {
        existingServices.contains(service)
    }

    func removeItems(forService service: String) throws {
        removedServices.append(service)
        existingServices.remove(service)
    }
}

/// 拦截 `trashItem`，避免把测试产物真的丢进用户废纸篓。
final class StubFileManager: FileManager, @unchecked Sendable {
    private(set) var trashedURLs: [URL] = []

    override func trashItem(
        at url: URL,
        resultingItemURL: AutoreleasingUnsafeMutablePointer<NSURL?>?
    ) throws {
        trashedURLs.append(url)
        try removeItem(at: url)
    }
}

// MARK: - 临时目录夹具

struct UninstallFixture {
    let root: URL
    let locations: UninstallLocations
    let appBundle: URL

    init(appBundleName: String = "Wakey.app") throws {
        root = FileManager.default.temporaryDirectory
            .appendingPathComponent("ProviderAppUninstallTests-\(UUID().uuidString)", isDirectory: true)
        let library = root.appendingPathComponent("Library", isDirectory: true)
        let support = library.appendingPathComponent("Application Support", isDirectory: true)
        let groups = library.appendingPathComponent("Group Containers", isDirectory: true)
        let caches = library.appendingPathComponent("Caches", isDirectory: true)
        let savedState = library.appendingPathComponent("Saved Application State", isDirectory: true)
        let preferences = library.appendingPathComponent("Preferences", isDirectory: true)
        let webKit = library.appendingPathComponent("WebKit", isDirectory: true)
        let containers = library.appendingPathComponent("Containers", isDirectory: true)
        let cookies = library.appendingPathComponent("Cookies", isDirectory: true)
        appBundle = root.appendingPathComponent("Applications/\(appBundleName)", isDirectory: true)
        locations = UninstallLocations(
            applicationSupportDirectory: support,
            groupContainersDirectory: groups,
            cachesDirectory: caches,
            savedApplicationStateDirectory: savedState,
            preferencesDirectory: preferences,
            webKitDirectory: webKit,
            containersDirectory: containers,
            cookiesDirectory: cookies,
            applicationBundleURL: appBundle
        )
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    }

    func cleanup() {
        try? FileManager.default.removeItem(at: root)
    }

    func write(_ relativePath: String, contents: String = "data") throws {
        let url = root.appendingPathComponent(relativePath)
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try Data(contents.utf8).write(to: url)
    }

    func makeDirectory(_ relativePath: String) throws {
        try FileManager.default.createDirectory(
            at: root.appendingPathComponent(relativePath),
            withIntermediateDirectories: true
        )
    }

    func exists(_ relativePath: String) -> Bool {
        FileManager.default.fileExists(atPath: root.appendingPathComponent(relativePath).path)
    }
}

/// 覆盖白名单之外的目标类型（App Group、缓存、Keychain）与失败分支。
@Suite("卸载目标发现与删除")
struct UninstallProviderBehaviourTests {
    private func makeScope(
        bundleID: String = "com.coffic.wakey",
        appGroup: String? = nil,
        cacheBundle: String? = nil,
        preferenceDomain: String = "com.coffic.wakey",
        keychainService: String? = nil
    ) -> UninstallScope {
        UninstallScope(
            bundleIdentifiers: [bundleID],
            appGroupIdentifiers: appGroup.map { [$0] } ?? [],
            preferenceDomains: [preferenceDomain],
            cacheBundleIdentifiers: cacheBundle.map { [$0] } ?? [],
            legacyApplicationSupportDirectories: [],
            keychainServices: keychainService.map { [$0] } ?? []
        )
    }

    @Test("扫描发现 App Group 目录")
    func scanFindsAppGroup() async throws {
        let fixture = try UninstallFixture()
        defer { fixture.cleanup() }
        try fixture.makeDirectory("Library/Group Containers/group.com.coffic.wakey")

        let provider = DefaultUninstallProvider(
            locations: fixture.locations,
            scope: makeScope(appGroup: "group.com.coffic.wakey"),
            persistentDomainRemover: StubDomainRemover(),
            keychainManager: StubKeychainManager()
        )

        let scan = await provider.scan()
        let groups = scan.targets.filter { $0.kind == .appGroup }

        #expect(groups.count == 1)
        #expect(groups.first?.id == "app-group.group.com.coffic.wakey")
    }

    @Test("卸载会删除 App Group 目录")
    func uninstallRemovesAppGroup() async throws {
        let fixture = try UninstallFixture()
        defer { fixture.cleanup() }
        try fixture.makeDirectory("Library/Group Containers/group.com.coffic.wakey")

        let provider = DefaultUninstallProvider(
            locations: fixture.locations,
            scope: makeScope(appGroup: "group.com.coffic.wakey"),
            persistentDomainRemover: StubDomainRemover(),
            keychainManager: StubKeychainManager()
        )

        let result = try await provider.uninstall(options: UninstallOptions(
            confirmation: UninstallOptions.confirmationPhrase,
            removeKeychainCredentials: true,
            removeApplication: false
        ))

        #expect(result.succeeded)
        #expect(result.removedTargetIDs.contains("app-group.group.com.coffic.wakey"))
        #expect(fixture.exists("Library/Group Containers/group.com.coffic.wakey") == false)
    }

    @Test("扫描发现缓存目录并统计体积")
    func scanFindsCaches() async throws {
        let fixture = try UninstallFixture()
        defer { fixture.cleanup() }
        try fixture.write("Library/Caches/com.coffic.wakey/blob.bin", contents: String(repeating: "x", count: 128))

        let provider = DefaultUninstallProvider(
            locations: fixture.locations,
            scope: makeScope(cacheBundle: "com.coffic.wakey"),
            persistentDomainRemover: StubDomainRemover(),
            keychainManager: StubKeychainManager()
        )

        let scan = await provider.scan()
        let caches = scan.targets.filter { $0.kind == .caches }

        #expect(caches.isEmpty == false)
        #expect(scan.totalSizeInBytes > 0)
    }

    @Test("卸载会删除缓存目录")
    func uninstallRemovesCaches() async throws {
        let fixture = try UninstallFixture()
        defer { fixture.cleanup() }
        try fixture.write("Library/Caches/com.coffic.wakey/blob.bin")

        let provider = DefaultUninstallProvider(
            locations: fixture.locations,
            scope: makeScope(cacheBundle: "com.coffic.wakey"),
            persistentDomainRemover: StubDomainRemover(),
            keychainManager: StubKeychainManager()
        )

        let result = try await provider.uninstall(options: UninstallOptions(
            confirmation: UninstallOptions.confirmationPhrase,
            removeKeychainCredentials: true,
            removeApplication: false
        ))

        #expect(result.succeeded)
        #expect(fixture.exists("Library/Caches/com.coffic.wakey") == false)
    }

    @Test("扫描发现存在条目的 Keychain 服务")
    func scanFindsKeychainService() async throws {
        let fixture = try UninstallFixture()
        defer { fixture.cleanup() }

        let provider = DefaultUninstallProvider(
            locations: fixture.locations,
            scope: makeScope(keychainService: "com.coffic.wakey.credentials"),
            persistentDomainRemover: StubDomainRemover(),
            keychainManager: StubKeychainManager(existingServices: ["com.coffic.wakey.credentials"])
        )

        let scan = await provider.scan()
        let keychain = scan.targets.filter { $0.kind == .keychain }

        #expect(keychain.count == 1)
        #expect(keychain.first?.id == "keychain.com.coffic.wakey.credentials")
        #expect(keychain.first?.isSensitive == true)
    }

    @Test("选择删除凭据时移除对应 Keychain 服务")
    func uninstallRemovesKeychainService() async throws {
        let fixture = try UninstallFixture()
        defer { fixture.cleanup() }

        let keychain = StubKeychainManager(existingServices: ["com.coffic.wakey.credentials"])
        let provider = DefaultUninstallProvider(
            locations: fixture.locations,
            scope: makeScope(keychainService: "com.coffic.wakey.credentials"),
            persistentDomainRemover: StubDomainRemover(),
            keychainManager: keychain
        )

        let result = try await provider.uninstall(options: UninstallOptions(
            confirmation: UninstallOptions.confirmationPhrase,
            removeKeychainCredentials: true,
            removeApplication: false
        ))

        #expect(result.succeeded)
        #expect(keychain.removedServices == ["com.coffic.wakey.credentials"])
    }

    @Test("未选择删除凭据时保留 Keychain 服务")
    func uninstallKeepsKeychainWhenNotRequested() async throws {
        let fixture = try UninstallFixture()
        defer { fixture.cleanup() }

        let keychain = StubKeychainManager(existingServices: ["com.coffic.wakey.credentials"])
        let provider = DefaultUninstallProvider(
            locations: fixture.locations,
            scope: makeScope(keychainService: "com.coffic.wakey.credentials"),
            persistentDomainRemover: StubDomainRemover(),
            keychainManager: keychain
        )

        let result = try await provider.uninstall(options: UninstallOptions(
            confirmation: UninstallOptions.confirmationPhrase,
            removeKeychainCredentials: false,
            removeApplication: false
        ))

        #expect(result.succeeded)
        #expect(keychain.removedServices.isEmpty)
    }

    @Test("偏好设置域有值时即使没有 plist 也会被扫描到")
    func scanFindsPreferencesWithPersistentDomain() async throws {
        let fixture = try UninstallFixture()
        defer { fixture.cleanup() }

        let domain = "com.coffic.wakey.tests.\(UUID().uuidString)"
        UserDefaults.standard.setPersistentDomain(["flag": true], forName: domain)
        defer { UserDefaults.standard.removePersistentDomain(forName: domain) }

        let provider = DefaultUninstallProvider(
            locations: fixture.locations,
            scope: makeScope(preferenceDomain: domain),
            persistentDomainRemover: StubDomainRemover(),
            keychainManager: StubKeychainManager()
        )

        let scan = await provider.scan()
        let preferences = scan.targets.filter { $0.kind == .preferences }

        #expect(preferences.count == 1)
        #expect(preferences.first?.id == "preferences.\(domain)")
    }

    @Test("删除失败时记录失败信息且不视为成功")
    func uninstallRecordsFailure() async throws {
        let fixture = try UninstallFixture()
        defer { fixture.cleanup() }
        try fixture.write("Library/Preferences/com.coffic.wakey.plist")

        let domainRemover = StubDomainRemover()
        domainRemover.errorToThrow = NSError(domain: "test", code: 7, userInfo: [NSLocalizedDescriptionKey: "删除失败"])
        let provider = DefaultUninstallProvider(
            locations: fixture.locations,
            scope: makeScope(),
            persistentDomainRemover: domainRemover,
            keychainManager: StubKeychainManager()
        )

        let result = try await provider.uninstall(options: UninstallOptions(
            confirmation: UninstallOptions.confirmationPhrase,
            removeKeychainCredentials: true,
            removeApplication: false
        ))

        #expect(result.succeeded == false)
        #expect(result.failures.count == 1)
        #expect(result.failures.first?.targetID == "preferences.com.coffic.wakey")
        #expect(result.failures.first?.message == "删除失败")
        #expect(domainRemover.removedDomains == ["com.coffic.wakey"])
    }

    @Test("有失败时不删除应用程序")
    func applicationIsKeptWhenOtherTargetsFail() async throws {
        let fixture = try UninstallFixture()
        defer { fixture.cleanup() }
        try fixture.write("Library/Preferences/com.coffic.wakey.plist")
        try fixture.makeDirectory("Applications/Wakey.app")

        let domainRemover = StubDomainRemover()
        domainRemover.errorToThrow = NSError(domain: "test", code: 7, userInfo: [NSLocalizedDescriptionKey: "删除失败"])
        let fileManager = StubFileManager()
        let provider = DefaultUninstallProvider(
            locations: fixture.locations,
            scope: makeScope(),
            persistentDomainRemover: domainRemover,
            keychainManager: StubKeychainManager(),
            fileManager: fileManager
        )

        let result = try await provider.uninstall(options: UninstallOptions(
            confirmation: UninstallOptions.confirmationPhrase,
            removeKeychainCredentials: true,
            removeApplication: true
        ))

        #expect(result.succeeded == false)
        #expect(result.applicationMovedToTrash == false)
        #expect(fileManager.trashedURLs.isEmpty)
    }

    @Test("选择删除应用时把应用包移到废纸篓")
    func uninstallMovesApplicationToTrash() async throws {
        let fixture = try UninstallFixture()
        defer { fixture.cleanup() }
        try fixture.makeDirectory("Applications/Wakey.app")

        let fileManager = StubFileManager()
        let provider = DefaultUninstallProvider(
            locations: fixture.locations,
            scope: makeScope(),
            persistentDomainRemover: StubDomainRemover(),
            keychainManager: StubKeychainManager(),
            fileManager: fileManager
        )

        let result = try await provider.uninstall(options: UninstallOptions(
            confirmation: UninstallOptions.confirmationPhrase,
            removeKeychainCredentials: true,
            removeApplication: true
        ))

        #expect(result.succeeded)
        #expect(result.applicationMovedToTrash)
        #expect(result.removedTargetIDs.contains("application"))
        #expect(fileManager.trashedURLs.map(\.lastPathComponent) == ["Wakey.app"])
    }

    @Test("不选择删除应用时保留应用包")
    func uninstallKeepsApplicationWhenNotRequested() async throws {
        let fixture = try UninstallFixture()
        defer { fixture.cleanup() }
        try fixture.makeDirectory("Applications/Wakey.app")

        let fileManager = StubFileManager()
        let provider = DefaultUninstallProvider(
            locations: fixture.locations,
            scope: makeScope(),
            persistentDomainRemover: StubDomainRemover(),
            keychainManager: StubKeychainManager(),
            fileManager: fileManager
        )

        let result = try await provider.uninstall(options: UninstallOptions(
            confirmation: UninstallOptions.confirmationPhrase,
            removeKeychainCredentials: true,
            removeApplication: false
        ))

        #expect(result.succeeded)
        #expect(result.applicationMovedToTrash == false)
        #expect(fileManager.trashedURLs.isEmpty)
        #expect(fixture.exists("Applications/Wakey.app"))
    }

    @Test("应用包不是 .app 后缀时按不安全目标拒绝并记录失败")
    func rejectsApplicationWithoutAppExtension() async throws {
        let fixture = try UninstallFixture(appBundleName: "Wakey")
        defer { fixture.cleanup() }
        try fixture.makeDirectory("Applications/Wakey")

        let fileManager = StubFileManager()
        let provider = DefaultUninstallProvider(
            locations: fixture.locations,
            scope: makeScope(),
            persistentDomainRemover: StubDomainRemover(),
            keychainManager: StubKeychainManager(),
            fileManager: fileManager
        )

        let result = try await provider.uninstall(options: UninstallOptions(
            confirmation: UninstallOptions.confirmationPhrase,
            removeKeychainCredentials: true,
            removeApplication: true
        ))

        #expect(result.succeeded == false)
        #expect(result.applicationMovedToTrash == false)
        #expect(result.failures.first?.targetID == "application")
        #expect(fileManager.trashedURLs.isEmpty)
    }

    @Test("扫描结果按目标类型与位置排序")
    func scanIsSorted() async throws {
        let fixture = try UninstallFixture()
        defer { fixture.cleanup() }
        try fixture.write("Library/Application Support/com.coffic.wakey/data.txt")
        try fixture.write("Library/Preferences/com.coffic.wakey.plist")

        let provider = DefaultUninstallProvider(
            locations: fixture.locations,
            scope: makeScope(),
            persistentDomainRemover: StubDomainRemover(),
            keychainManager: StubKeychainManager()
        )

        let scan = await provider.scan()
        let keys = scan.targets.map { "\($0.kind.rawValue)|\($0.location)" }
        #expect(keys == keys.sorted())
    }

    @Test("重复 id 的目标只会被记录一次")
    func duplicateTargetIDsAreCollapsed() async throws {
        let fixture = try UninstallFixture()
        defer { fixture.cleanup() }
        try fixture.write("Library/Application Support/com.coffic.wakey/data.txt")

        let scope = UninstallScope(
            bundleIdentifiers: ["com.coffic.wakey", "com.coffic.wakey"],
            appGroupIdentifiers: [],
            preferenceDomains: ["com.coffic.wakey"],
            cacheBundleIdentifiers: [],
            legacyApplicationSupportDirectories: [],
            keychainServices: []
        )
        let provider = DefaultUninstallProvider(
            locations: fixture.locations,
            scope: scope,
            persistentDomainRemover: StubDomainRemover(),
            keychainManager: StubKeychainManager()
        )

        let scan = await provider.scan()
        let ids = scan.targets.map(\.id)
        #expect(Set(ids).count == ids.count)
    }
}

/// `DefaultUninstallPersistentDomainRemover` 与 `DefaultUninstallKeychainManager`
/// 直接接触 `UserDefaults.standard` 与系统钥匙串，因此只验证不会破坏既有数据的部分。
@Suite("默认持久化与钥匙串实现")
struct DefaultUninstallSystemTests {
    @Test("默认实现会真正移除持久化域")
    func defaultDomainRemoverRemovesDomain() {
        let domain = "com.coffic.wakey.tests.\(UUID().uuidString)"
        UserDefaults.standard.setPersistentDomain(["flag": true], forName: domain)
        let existed = UserDefaults.standard.persistentDomain(forName: domain)
        #expect(existed?.isEmpty == false)


        try? DefaultUninstallPersistentDomainRemover().removePersistentDomain(named: domain)

        let after = UserDefaults.standard.persistentDomain(forName: domain)
        #expect(after == nil || after?.isEmpty == true)
    }

    @Test("默认钥匙串实现对不存在的服务报告无条目")
    func defaultKeychainReportsNoItems() {
        let service = "com.coffic.wakey.tests.\(UUID().uuidString)"
        let manager = DefaultUninstallKeychainManager()
        #expect(manager.containsItems(forService: service) == false)
    }

    @Test("默认钥匙串实现删除不存在的服务后仍无条目")
    func defaultKeychainRemovalLeavesNoItems() {
        let service = "com.coffic.wakey.tests.\(UUID().uuidString)"
        let manager = DefaultUninstallKeychainManager()
        // 未授权的测试进程可能因缺少钥匙串权限而抛错，两种结果都不应留下条目。
        try? manager.removeItems(forService: service)
        #expect(manager.containsItems(forService: service) == false)
    }
}
