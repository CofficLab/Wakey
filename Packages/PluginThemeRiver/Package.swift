// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeRiver",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginThemeRiver", targets: ["PluginThemeRiver"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../ProviderTheme"),
    ],
    targets: [
        .target(
            name: "PluginThemeRiver",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "ProviderTheme",
            ]
        )
    ]
)
