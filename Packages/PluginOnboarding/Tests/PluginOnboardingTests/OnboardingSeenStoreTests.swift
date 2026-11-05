import Foundation
import Testing
@testable import PluginOnboarding

/// `OnboardingSeenStore` 用插件目录下的 `completed` 标记文件记录引导是否看过，
/// 是 onboarding 首次展示判定的唯一持久化来源。
@Suite("OnboardingSeenStore")
@MainActor
struct OnboardingSeenStoreTests {
    private func makeStore() -> (OnboardingSeenStore, URL) {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("OnboardingSeenStoreTests-\(UUID().uuidString)", isDirectory: true)
        return (OnboardingSeenStore(directory: directory), directory)
    }

    @Test("新建 store 未标记为已看")
    func startsUnseen() {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        #expect(!store.hasSeen)
    }

    @Test("标记后 hasSeen 变为 true")
    func marksSeen() {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        store.markSeen()
        #expect(store.hasSeen)
    }

    @Test("reset 后恢复为未看")
    func resetsToUnseen() {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        store.markSeen()
        #expect(store.hasSeen)

        store.reset()
        #expect(!store.hasSeen)
    }

    @Test("重复标记保持幂等")
    func markingIsIdempotent() {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        store.markSeen()
        store.markSeen()
        #expect(store.hasSeen)
    }

    @Test("未标记时 reset 不抛错")
    func resettingUnseenIsSafe() {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        store.reset()
        #expect(!store.hasSeen)
    }

    @Test("标记文件落在插件目录下且名为 completed")
    func writesExpectedMarkerFile() throws {
        let (store, directory) = makeStore()
        defer { try? FileManager.default.removeItem(at: directory) }

        store.markSeen()

        let marker = directory.appendingPathComponent("completed")
        #expect(FileManager.default.fileExists(atPath: marker.path))
    }

    @Test("init 会创建不存在的目录")
    func createsDirectoryIfNeeded() {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("OnboardingSeenStoreTests-\(UUID().uuidString)", isDirectory: true)
        let nested = root.appendingPathComponent("nested/deeper", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }

        #expect(!FileManager.default.fileExists(atPath: nested.path))
        _ = OnboardingSeenStore(directory: nested)
        #expect(FileManager.default.fileExists(atPath: nested.path))
    }

    @Test("已有标记文件的目录会恢复为已看")
    func reopensWithExistingMarker() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("OnboardingSeenStoreTests-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try Data("completed".utf8)
            .write(to: directory.appendingPathComponent("completed"))

        #expect(OnboardingSeenStore(directory: directory).hasSeen)
    }
}
