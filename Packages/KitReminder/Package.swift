// swift-tools-version: 6.0
import PackageDescription

/// 共享的「休息提醒」基础设施。
///
/// 护眼 / 喝水 / 拉伸三个插件的 Manager 此前各自直接依赖
/// `Date()`、`UserDefaults.standard`、`Timer.scheduledTimer`
/// 与真实 NSWindow 弹层，且都是 `private init` 单例，
/// 导致其状态机逻辑无法在单元测试中验证。
///
/// 本包把这些外部依赖抽象为 `ReminderEnvironment` 协议：
/// 生产环境由 `SystemReminderEnvironment` 提供真实实现，
/// 测试可注入可控实现精确推进虚拟时钟。
let package = Package(
    name: "KitReminder",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "KitReminder", targets: ["KitReminder"])
    ],
    targets: [
        .target(name: "KitReminder"),
        .testTarget(
            name: "KitReminderTests",
            dependencies: ["KitReminder"]
        ),
    ]
)
