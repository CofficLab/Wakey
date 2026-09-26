// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeSwitcher",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginThemeSwitcher", targets: ["PluginThemeSwitcher"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(url: "https://github.com/CofficLab/LumiUI.git", from: "1.7.0"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../ProviderTheme"),
    ],
    targets: [
        .target(
            name: "PluginThemeSwitcher",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "LumiUI", package: "LumiUI"),
                "ProviderWakeyHost",
                "ProviderTheme",
            ]
        )
    ]
)
