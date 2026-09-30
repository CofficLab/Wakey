// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginHydrationReminder",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginHydrationReminder", targets: ["PluginHydrationReminder"])
    ],
    dependencies: [
        .package(path: "../ProviderStatusBarPopup"),
        .package(path: "../ProviderSettingsView"),
        .package(path: "../KitLogging"),
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(url: "https://github.com/CofficLab/LumiUI.git", from: "1.7.0"),
    ],
    targets: [
        .target(
            name: "PluginHydrationReminder",
            dependencies: [
                "ProviderStatusBarPopup",
                "ProviderSettingsView",
                "KitLogging",
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "LumiUI", package: "LumiUI"),


            ],
            resources: [.process("HydrationReminder.xcstrings")]
        )
    ]
)
