// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemePack",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginThemePack", targets: ["PluginThemePack"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(url: "https://github.com/CofficLab/LumiUI.git", from: "1.7.0"),
        .package(path: "../ProviderTheme"),
        .package(path: "../ProviderWakeyHost"),
    ],
    targets: [
        .target(
            name: "PluginThemePack",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "LumiUI", package: "LumiUI"),
                "ProviderTheme",
                "ProviderWakeyHost",
            ]
        )
    ]
)
