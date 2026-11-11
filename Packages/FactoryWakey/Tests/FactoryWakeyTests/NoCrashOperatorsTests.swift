import Foundation
import Testing
@testable import FactoryWakey

/// 应用装配层不应包含会在用户机器上直接崩溃的操作符。
@Suite("装配层无崩溃操作符")
struct NoCrashOperatorsTests {
    private var sourcesDirectory: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/FactoryWakey")
    }

    @Test("FactoryWakey 源码中没有 try! 与 fatalError")
    func noCrashingOperators() throws {
        let enumerator = FileManager.default.enumerator(
            at: sourcesDirectory,
            includingPropertiesForKeys: nil
        )
        var files: [URL] = []
        while let url = enumerator?.nextObject() as? URL {
            guard url.pathExtension == "swift" else { continue }
            files.append(url)
        }
        // 防呆：枚举器为空说明路径变了，本用例会静默通过。断言的是「扫到了
        // 装配层的文件」，而不是某个具体数量——文件数会随死代码清理增减。
        #expect(files.contains { $0.lastPathComponent == "FactoryWakey.swift" })
        for file in files {
            let text = try String(contentsOf: file, encoding: .utf8)
            for (index, line) in text.split(separator: "\n", omittingEmptySubsequences: false).enumerated() {
                #expect(
                    !line.contains("try!"),
                    "\(file.lastPathComponent):\(index + 1) 使用了 try!"
                )
                #expect(
                    !line.contains("fatalError"),
                    "\(file.lastPathComponent):\(index + 1) 使用了 fatalError"
                )
            }
        }
    }
}
