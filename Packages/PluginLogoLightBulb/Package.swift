// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginLogoLightBulb",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginLogoLightBulb", targets: ["PluginLogoLightBulb"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "PluginLogoLightBulb",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
