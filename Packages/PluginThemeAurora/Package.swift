// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeAurora",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginThemeAurora", targets: ["PluginThemeAurora"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "PluginThemeAurora",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
