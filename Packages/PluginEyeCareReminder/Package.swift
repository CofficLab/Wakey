// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginEyeCareReminder",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginEyeCareReminder", targets: ["PluginEyeCareReminder"])
    ],
    dependencies: [
        .package(path: "../KitLogging"),
        .package(url: "https://github.com/CofficLab/LumiKitReminder.git", from: "1.0.0"),
        .package(url: "https://github.com/CofficLab/LumiProviders.git", from: "1.18.0"),
        .package(url: "https://github.com/CofficLab/LumiSettings.git", from: "1.1.0"),
        .package(url: "https://github.com/CofficLab/LumiKernel.git", from: "1.1.0"),
        .package(url: "https://github.com/CofficLab/LumiUI.git", from: "1.11.1"),
    ],
    targets: [
        .target(
            name: "PluginEyeCareReminder",
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
            resources: [.process("EyeCareReminder.xcstrings")]
        ),
        .testTarget(
            name: "PluginEyeCareReminderTests",
            dependencies: [
                "PluginEyeCareReminder",
                .product(name: "KitReminder", package: "LumiKitReminder"),
                .product(name: "ProviderDocsView", package: "LumiProviders"),
                .product(name: "ProviderMenuBar", package: "LumiProviders"),
            ]
        ),
    ]
)
