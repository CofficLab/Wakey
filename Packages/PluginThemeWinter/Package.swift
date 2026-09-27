// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeWinter",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginThemeWinter", targets: ["PluginThemeWinter"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiThemePack.git", from: "1.0.2"),
        .package(url: "https://github.com/CofficLab/LumiProviders.git", from: "1.1.1"),
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
    ],
    targets: [
        .target(
            name: "PluginThemeWinter",
            dependencies: [
                .product(name: "LumiThemePack", package: "LumiThemePack"),
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                .product(name: "ProviderTheme", package: "LumiProviders"),
            ]
        )
    ]
)
