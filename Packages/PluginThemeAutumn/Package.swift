// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeAutumn",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginThemeAutumn", targets: ["PluginThemeAutumn"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "PluginThemeAutumn",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
