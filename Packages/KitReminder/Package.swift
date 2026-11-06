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
///
/// 插件状态（间隔、每日计数等）按 CofficLab 兄弟项目的存储规范落盘：
/// 由宿主的 `StorageProviding` 分配插件专属目录，状态写入目录下的
/// Binary Plist，而不是 `UserDefaults.standard`。
let package = Package(
    name: "KitReminder",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "KitReminder", targets: ["KitReminder"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiProviders.git", from: "1.18.0"),
        .package(url: "https://github.com/CofficLab/LumiKernel.git", from: "1.1.0"),
        .package(url: "https://github.com/CofficLab/LumiUI.git", from: "1.11.1"),
    ],
    targets: [
        .target(
            name: "KitReminder",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "ProviderStorage", package: "LumiProviders"),
                .product(name: "LumiUI", package: "LumiUI"),
            ]
        ),
        .testTarget(
            name: "KitReminderTests",
            dependencies: [
                "KitReminder",
                .product(name: "ProviderStorage", package: "LumiProviders"),
            ]
        ),
    ]
)
