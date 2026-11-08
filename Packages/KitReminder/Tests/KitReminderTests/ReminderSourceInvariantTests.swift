import Foundation
import Testing
@testable import KitReminder

@Suite("提醒源码不变量")
struct ReminderSourceInvariantTests {
    /// Packages/ 根目录。
    private var packagesRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent() // ReminderSourceInvariantTests.swift
            .deletingLastPathComponent() // KitReminderTests
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent() // KitReminder
            .deletingLastPathComponent() // Packages
    }

    private func statusInfoFiles() throws -> [URL] {
        let enumerator = FileManager.default.enumerator(
            at: packagesRoot,
            includingPropertiesForKeys: nil
        )
        var files: [URL] = []
        while let url = enumerator?.nextObject() as? URL {
            guard url.lastPathComponent.hasSuffix("StatusInfo.swift") else { continue }
            guard url.path.contains("/Plugin"), url.path.contains("/Sources/"), !url.path.contains("/.build/") else { continue }
            files.append(url)
        }
        return files
    }

    /// 状态栏弹窗的倒计时只需要分钟级刷新。历史实现用 1 Hz 计时器，
    /// 弹窗关闭后仍持续唤醒主线程。
    @Test("状态栏倒计时不出现亚分钟级计时器")
    func statusInfoTimersAreMinuteGranular() throws {
        let files = try statusInfoFiles()
        #expect(files.count == 3, "应扫描到三个提醒插件的 StatusInfo.swift，实际 \(files.count)")
        for file in files {
            let lines = try String(contentsOf: file, encoding: .utf8)
                .split(separator: "\n", omittingEmptySubsequences: false)
            for (index, line) in lines.enumerated() where line.contains("Timer.publish") {
                #expect(
                    line.contains("every: 60"),
                    "\(file.lastPathComponent):\(index + 1) 使用了非分钟级计时器"
                )
            }
        }
    }
}
