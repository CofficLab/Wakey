// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeGithub",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginThemeGithub", targets: ["PluginThemeGithub"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "PluginThemeGithub",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
