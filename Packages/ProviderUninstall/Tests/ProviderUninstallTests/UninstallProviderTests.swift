import Foundation
import Testing
@testable import ProviderUninstall

private final class RecordingDomainRemover: UninstallPersistentDomainRemoving, @unchecked Sendable {
    private(set) var removedDomains: [String] = []

    func removePersistentDomain(named name: String) throws {
        removedDomains.append(name)
    }
}

private final class RecordingKeychainManager: UninstallKeychainManaging, @unchecked Sendable {
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

@Suite("ProviderUninstall")
struct UninstallProviderTests {
    private struct Fixture {
        let root: URL
        let locations: UninstallLocations
        let appBundle: URL

        init() throws {
            root = FileManager.default.temporaryDirectory
                .appendingPathComponent("ProviderUninstallTests-\(UUID().uuidString)", isDirectory: true)
            let library = root.appendingPathComponent("Library", isDirectory: true)
            let support = library.appendingPathComponent("Application Support", isDirectory: true)
            let groups = library.appendingPathComponent("Group Containers", isDirectory: true)
            let caches = library.appendingPathComponent("Caches", isDirectory: true)
            let savedState = library.appendingPathComponent("Saved Application State", isDirectory: true)
            let preferences = library.appendingPathComponent("Preferences", isDirectory: true)
            let webKit = library.appendingPathComponent("WebKit", isDirectory: true)
            let containers = library.appendingPathComponent("Containers", isDirectory: true)
            let cookies = library.appendingPathComponent("Cookies", isDirectory: true)
            appBundle = root.appendingPathComponent("Applications/Wakey.app", isDirectory: true)
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

        func write(_ relativePath: String, contents: String = "data") throws {
            let url = root.appendingPathComponent(relativePath)
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try Data(contents.utf8).write(to: url)
        }
    }

    @Test("根据 Bundle ID 选择正确的卸载 scope")
    func liveScopeMatchesBundleIdentifier() {
        #expect(UninstallScope.live(bundleIdentifier: "com.coffic.wakey.debug") == .debug)
        #expect(UninstallScope.live(bundleIdentifier: "com.coffic.wakey") == .production)
    }

    @Test("扫描只发现 Wakey 白名单目标")
    func scanFindsOnlyWakeyOwnedTargets() async throws {
        let fixture = try Fixture()
        try fixture.write("Library/Application Support/com.coffic.wakey/db_production_v5/com.example.plugin/data.sqlite")
        try fixture.write("Library/Application Support/OtherApp/data.sqlite")
        try fixture.write("Library/Preferences/com.coffic.wakey.plist")

        let keychain = RecordingKeychainManager(existingServices: [])
        let provider = DefaultUninstallProvider(
            locations: fixture.locations,
            persistentDomainRemover: RecordingDomainRemover(),
            keychainManager: keychain
        )

        let scan = await provider.scan()
        let locations = scan.targets.map(\.location)

        #expect(locations.contains { $0.contains("com.coffic.wakey") })
        #expect(!locations.contains { $0.contains("OtherApp") })
    }

    @Test("卸载删除数据与偏好设置，但不删除用户项目目录")
    func uninstallRemovesOwnedDataOnly() async throws {
        let fixture = try Fixture()
        try fixture.write("Library/Application Support/com.coffic.wakey/db_production_v4/old/data.sqlite")
        try fixture.write("Library/Application Support/com.coffic.wakey/db_production_v5/plugin/data.sqlite")
        try fixture.write("Library/Application Support/com.coffic.wakey/db_production_v6/current/data.sqlite")
        try fixture.write("Library/Preferences/com.coffic.wakey.plist")
        try fixture.write("Applications/Wakey.app/Contents/Info.plist")
        try fixture.write("Documents/MyProject/main.swift")

        let domainRemover = RecordingDomainRemover()
        let keychain = RecordingKeychainManager(existingServices: [])
        let provider = DefaultUninstallProvider(
            locations: fixture.locations,
            persistentDomainRemover: domainRemover,
            keychainManager: keychain
        )

        let result = try await provider.uninstall(options: UninstallOptions(
            confirmation: UninstallOptions.confirmationPhrase,
            removeKeychainCredentials: true,
            removeApplication: false
        ))

        #expect(result.succeeded)
        #expect(!FileManager.default.fileExists(atPath: fixture.locations.applicationSupportDirectory.appendingPathComponent("com.coffic.wakey").path))
        #expect(FileManager.default.fileExists(atPath: fixture.root.appendingPathComponent("Documents/MyProject/main.swift").path))
        #expect(domainRemover.removedDomains.contains("com.coffic.wakey"))
        #expect(keychain.removedServices.isEmpty)
    }

    @Test("确认短语不正确时不会删除任何内容")
    func invalidConfirmationDoesNotDelete() async throws {
        let fixture = try Fixture()
        try fixture.write("Library/Application Support/com.coffic.wakey/data.txt")
        let provider = DefaultUninstallProvider(locations: fixture.locations)

        await #expect(throws: UninstallError.invalidConfirmation) {
            try await provider.uninstall(options: UninstallOptions(
                confirmation: "删除",
                removeKeychainCredentials: true,
                removeApplication: true
            ))
        }

        #expect(FileManager.default.fileExists(atPath: fixture.locations.applicationSupportDirectory.appendingPathComponent("com.coffic.wakey/data.txt").path))
    }

    @Test("Debug 卸载不会删除 Release 数据")
    func debugScopeDoesNotDeleteProductionData() async throws {
        let fixture = try Fixture()
        try fixture.write("Library/Application Support/com.coffic.wakey/db_production_v5/production.sqlite")
        try fixture.write("Library/Application Support/com.coffic.wakey.debug/db_debug_v5/debug.sqlite")
        try fixture.write("Library/Preferences/com.coffic.wakey.plist")
        try fixture.write("Library/Preferences/com.coffic.wakey.debug.plist")

        let keychain = RecordingKeychainManager(existingServices: [])
        let provider = DefaultUninstallProvider(
            locations: fixture.locations,
            scope: .debug,
            persistentDomainRemover: RecordingDomainRemover(),
            keychainManager: keychain
        )

        let result = try await provider.uninstall(options: UninstallOptions(
            confirmation: UninstallOptions.confirmationPhrase,
            removeKeychainCredentials: true,
            removeApplication: false
        ))

        #expect(result.succeeded)
        #expect(FileManager.default.fileExists(atPath: fixture.locations.applicationSupportDirectory.appendingPathComponent("com.coffic.wakey/db_production_v5").path))
        #expect(!FileManager.default.fileExists(atPath: fixture.locations.applicationSupportDirectory.appendingPathComponent("com.coffic.wakey.debug/db_debug_v5").path))
    }
}
