// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginEyeCareReminder",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginEyeCareReminder", targets: ["PluginEyeCareReminder"])
    ],
    dependencies: [
        .package(path: "../ProviderStatusBarPopup"),
        .package(path: "../KitLogging"),
        .package(path: "../KitReminder"),
        .package(url: "https://github.com/CofficLab/LumiSettings.git", from: "1.1.0"),
        .package(url: "https://github.com/CofficLab/LumiKernel.git", from: "1.1.0"),
        .package(url: "https://github.com/CofficLab/LumiUI.git", from: "1.11.1"),
    ],
    targets: [
        .target(
            name: "PluginEyeCareReminder",
            dependencies: [
                "ProviderStatusBarPopup",
                "KitLogging",
                "KitReminder",
                .product(name: "ProviderSettingView", package: "LumiSettings"),
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "LumiUI", package: "LumiUI"),


            ],
            resources: [.process("EyeCareReminder.xcstrings")]
        ),
        .testTarget(
            name: "PluginEyeCareReminderTests",
            dependencies: ["PluginEyeCareReminder", "KitReminder"]
        ),
    ]
)
