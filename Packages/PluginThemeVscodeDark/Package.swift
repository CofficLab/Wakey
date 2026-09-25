// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeVscodeDark",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginThemeVscodeDark", targets: ["PluginThemeVscodeDark"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "PluginThemeVscodeDark",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
