// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginLogoNoSleep",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginLogoNoSleep", targets: ["PluginLogoNoSleep"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
    ],
    targets: [
        .target(
            name: "PluginLogoNoSleep",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
            ]
        )
    ]
)
