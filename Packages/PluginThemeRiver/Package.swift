// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeRiver",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginThemeRiver", targets: ["PluginThemeRiver"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiThemePack.git", from: "1.0.2"),
        .package(url: "https://github.com/CofficLab/LumiProviders.git", from: "1.1.1"),
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
    ],
    targets: [
        .target(
            name: "PluginThemeRiver",
            dependencies: [
                .product(name: "LumiThemePack", package: "LumiThemePack"),
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                .product(name: "ProviderTheme", package: "LumiProviders"),
            ]
        )
    ]
)
