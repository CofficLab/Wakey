import Foundation
import Testing
@testable import ProviderAppUninstall

@Suite("卸载数据模型")
struct UninstallValueTypeTests {
    @Test("所有目标类型都有非空且互不重复的展示名")
    func targetKindDisplayNames() {
        let kinds: [UninstallTargetKind] = [
            .applicationData, .legacyData, .caches, .appGroup,
            .preferences, .keychain, .application
        ]
        let names = kinds.map(\.displayName)
        #expect(names.allSatisfy { !$0.isEmpty })
        #expect(Set(names).count == names.count)
    }

    @Test("卸载目标保存传入的字段")
    func targetKeepsFields() {
        let target = UninstallTarget(
            id: "preferences.com.coffic.wakey",
            kind: .preferences,
            location: "/tmp/com.coffic.wakey.plist",
            sizeInBytes: 42,
            isSensitive: true
        )
        #expect(target.id == "preferences.com.coffic.wakey")
        #expect(target.kind == .preferences)
        #expect(target.location == "/tmp/com.coffic.wakey.plist")
        #expect(target.sizeInBytes == 42)
        #expect(target.isSensitive)
    }

    @Test("扫描结果汇总体积、是否有数据与 Keychain 条目数")
    func scanAggregates() {
        let empty = UninstallScan()
        #expect(empty.totalSizeInBytes == 0)
        #expect(empty.hasData == false)
        #expect(empty.keychainTargetCount == 0)

        let scan = UninstallScan(targets: [
            UninstallTarget(id: "a", kind: .applicationData, location: "/a", sizeInBytes: 10),
            UninstallTarget(id: "b", kind: .keychain, location: "Keychain service b", sizeInBytes: 5),
            UninstallTarget(id: "c", kind: .keychain, location: "Keychain service c", sizeInBytes: 7),
        ])
        #expect(scan.totalSizeInBytes == 22)
        #expect(scan.hasData)
        #expect(scan.keychainTargetCount == 2)
    }

    @Test("卸载选项保存用户选择并带有默认确认短语")
    func optionsKeepChoices() {
        let options = UninstallOptions(
            confirmation: UninstallOptions.confirmationPhrase,
            removeKeychainCredentials: true,
            removeApplication: false
        )
        #expect(options.confirmation == UninstallOptions.confirmationPhrase)
        #expect(options.removeKeychainCredentials)
        #expect(options.removeApplication == false)
        #expect(UninstallOptions.confirmationPhrase.isEmpty == false)
    }

    @Test("失败记录保存目标、位置与原因")
    func failureKeepsFields() {
        let failure = UninstallFailure(
            targetID: "application-support.com.coffic.wakey",
            location: "/tmp/data",
            message: "boom"
        )
        #expect(failure.targetID == "application-support.com.coffic.wakey")
        #expect(failure.location == "/tmp/data")
        #expect(failure.message == "boom")
    }

    @Test("没有失败时视为卸载成功")
    func resultSucceeded() {
        let ok = UninstallResult(removedTargetIDs: ["a"], failures: [], applicationMovedToTrash: false)
        #expect(ok.succeeded)
        #expect(ok.removedTargetIDs == ["a"])
        #expect(ok.applicationMovedToTrash == false)

        let failed = UninstallResult(
            removedTargetIDs: [],
            failures: [UninstallFailure(targetID: "a", location: "/a", message: "boom")],
            applicationMovedToTrash: false
        )
        #expect(failed.succeeded == false)
    }

    @Test("卸载错误都有可读描述")
    func errorDescriptions() {
        let invalid = UninstallError.invalidConfirmation
        let unsafe = UninstallError.unsafeTarget("/tmp/other")
        #expect(invalid.errorDescription?.isEmpty == false)
        #expect(unsafe.errorDescription?.contains("/tmp/other") == true)
        #expect(invalid.errorDescription != unsafe.errorDescription)
    }

    @Test("live 位置指向当前用户的 Library 目录")
    func liveLocationsPointAtLibrary() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let library = home.appendingPathComponent("Library", isDirectory: true)
        let locations = UninstallLocations.live(applicationBundleURL: nil)

        #expect(locations.applicationSupportDirectory == library.appendingPathComponent("Application Support", isDirectory: true))
        #expect(locations.groupContainersDirectory == library.appendingPathComponent("Group Containers", isDirectory: true))
        #expect(locations.cachesDirectory == library.appendingPathComponent("Caches", isDirectory: true))
        #expect(locations.savedApplicationStateDirectory == library.appendingPathComponent("Saved Application State", isDirectory: true))
        #expect(locations.preferencesDirectory == library.appendingPathComponent("Preferences", isDirectory: true))
        #expect(locations.webKitDirectory == library.appendingPathComponent("WebKit", isDirectory: true))
        #expect(locations.containersDirectory == library.appendingPathComponent("Containers", isDirectory: true))
        #expect(locations.cookiesDirectory == library.appendingPathComponent("Cookies", isDirectory: true))
        #expect(locations.applicationBundleURL == nil)
    }

    @Test("生产与调试 scope 的白名单互不重叠")
    func scopesAreSeparated() {
        #expect(UninstallScope.production.bundleIdentifiers == ["com.coffic.wakey", "com.coffic.Wakey"])
        #expect(UninstallScope.production.preferenceDomains == ["com.coffic.wakey", "com.coffic.Wakey"])
        #expect(UninstallScope.production.cacheBundleIdentifiers == ["com.coffic.wakey", "com.coffic.Wakey"])
        #expect(UninstallScope.production.legacyApplicationSupportDirectories == ["Wakey"])
        #expect(UninstallScope.production.appGroupIdentifiers.isEmpty)
        #expect(UninstallScope.production.keychainServices.isEmpty)

        #expect(UninstallScope.debug.bundleIdentifiers == ["com.coffic.wakey.debug"])
        #expect(UninstallScope.debug.preferenceDomains == ["com.coffic.wakey.debug"])
        #expect(UninstallScope.debug.cacheBundleIdentifiers == ["com.coffic.wakey.debug"])
        #expect(UninstallScope.debug.legacyApplicationSupportDirectories.isEmpty)

        let overlap = Set(UninstallScope.production.bundleIdentifiers)
            .intersection(UninstallScope.debug.bundleIdentifiers)
        #expect(overlap.isEmpty)
    }

    @Test("卸载通知名固定")
    func notificationNameIsStable() {
        #expect(Notification.Name.wakeyWillUninstall.rawValue == "com.coffic.wakey.uninstall.will-uninstall")
    }
}
