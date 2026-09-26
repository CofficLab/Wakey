// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginLogoSun",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginLogoSun", targets: ["PluginLogoSun"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
    ],
    targets: [
        .target(
            name: "PluginLogoSun",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
            ]
        )
    ]
)
