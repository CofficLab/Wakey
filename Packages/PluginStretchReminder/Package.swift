// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginStretchReminder",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginStretchReminder", targets: ["PluginStretchReminder"])
    ],
    dependencies: [
        .package(path: "../KitLogging"),
        .package(url: "https://github.com/CofficLab/LumiKitReminder.git", from: "1.0.1"),
        .package(url: "https://github.com/CofficLab/LumiProviders.git", from: "1.22.0"),
        .package(url: "https://github.com/CofficLab/LumiSettings.git", from: "1.1.0"),
        .package(url: "https://github.com/CofficLab/LumiKernel.git", from: "1.1.0"),
        .package(url: "https://github.com/CofficLab/LumiUI.git", from: "1.13.1"),
    ],
    targets: [
        .target(
            name: "PluginStretchReminder",
            dependencies: [
                .product(name: "ProviderMenuBar", package: "LumiProviders"),
                "KitLogging",
                .product(name: "KitReminder", package: "LumiKitReminder"),
                .product(name: "ProviderSettingView", package: "LumiSettings"),
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "ProviderStorage", package: "LumiProviders"),
                .product(name: "LumiUI", package: "LumiUI"),
                .product(name: "ProviderDocsView", package: "LumiProviders"),
            ],
            resources: [.process("StretchReminder.xcstrings")]
        ),
        .testTarget(
            name: "PluginStretchReminderTests",
            dependencies: [
                "PluginStretchReminder",
                .product(name: "ProviderDocsView", package: "LumiProviders"),
                .product(name: "ProviderMenuBar", package: "LumiProviders"),
            ]
        ),
    ]
)
