// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeOneDark",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginThemeOneDark", targets: ["PluginThemeOneDark"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "PluginThemeOneDark",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
