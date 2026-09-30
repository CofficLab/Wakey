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
        .package(url: "https://github.com/CofficLab/LumiSettings.git", from: "1.0.1"),
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(url: "https://github.com/CofficLab/LumiUI.git", from: "1.7.0"),
    ],
    targets: [
        .target(
            name: "PluginEyeCareReminder",
            dependencies: [
                "ProviderStatusBarPopup",
                                "KitLogging",
                .product(name: "ProviderSettingView", package: "LumiSettings"),
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "LumiUI", package: "LumiUI"),


            ],
            resources: [.process("EyeCareReminder.xcstrings")]
        )
    ]
)
