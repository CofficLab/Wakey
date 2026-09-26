// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginLogoRadar",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginLogoRadar", targets: ["PluginLogoRadar"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
    ],
    targets: [
        .target(
            name: "PluginLogoRadar",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
            ]
        )
    ]
)
