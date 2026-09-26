// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeSummer",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginThemeSummer", targets: ["PluginThemeSummer"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../ProviderTheme"),
    ],
    targets: [
        .target(
            name: "PluginThemeSummer",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "ProviderTheme",
            ]
        )
    ]
)
