@testable import Wakey
import Foundation
import KernelCore
import LumiFactory

/// 测试装配入口：与 App 走同一条共享流水线（清单 → KernelAssembler）。
///
/// 单测注入真实宿主进程运行，数据根必须隔离到临时目录：否则插件启用
/// 状态会读到用户真实 App 的存储（例如用户手动启用过系统测速，
/// 「默认禁用」类断言就会随用户环境变红）。
@MainActor
enum WakeyKernelFixture {
    static func makeKernel() async throws -> KernelCoreContainer {
        var manifest = WakeyManifest.manifest
        let dataRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("WakeyTests-\(UUID().uuidString)", isDirectory: true)
        manifest.storage.dataRootDirectoryOverride = { dataRoot }
        return try await KernelAssembler.makeKernel(manifest: manifest)
    }
}