// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginStretchReminder",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginStretchReminder", targets: ["PluginStretchReminder"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(url: "https://github.com/CofficLab/LumiUI.git", from: "1.0.1"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../MagicKit"),
    ],
    targets: [
        .target(
            name: "PluginStretchReminder",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "LumiUI", package: "LumiUI"),
                "ProviderWakeyHost",
                "MagicKit",
            ]
        )
    ]
)
