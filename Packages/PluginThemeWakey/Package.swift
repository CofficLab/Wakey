// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeWakey",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginThemeWakey", targets: ["PluginThemeWakey"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../ProviderTheme"),
    ],
    targets: [
        .target(
            name: "PluginThemeWakey",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "ProviderTheme",
            ]
        )
    ]
)
