// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeVscodeLight",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginThemeVscodeLight", targets: ["PluginThemeVscodeLight"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../ProviderTheme"),
    ],
    targets: [
        .target(
            name: "PluginThemeVscodeLight",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "ProviderTheme",
            ]
        )
    ]
)
