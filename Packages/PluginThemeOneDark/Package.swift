// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeOneDark",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginThemeOneDark", targets: ["PluginThemeOneDark"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiThemePack.git", from: "1.0.2"),
        .package(url: "https://github.com/CofficLab/LumiProviders.git", from: "1.1.1"),
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
    ],
    targets: [
        .target(
            name: "PluginThemeOneDark",
            dependencies: [
                .product(name: "LumiThemePack", package: "LumiThemePack"),
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                .product(name: "ProviderTheme", package: "LumiProviders"),
            ]
        )
    ]
)
