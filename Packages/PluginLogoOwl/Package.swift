// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginLogoOwl",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginLogoOwl", targets: ["PluginLogoOwl"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
    ],
    targets: [
        .target(
            name: "PluginLogoOwl",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
            ]
        )
    ]
)
