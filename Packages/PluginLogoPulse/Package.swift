// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginLogoPulse",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginLogoPulse", targets: ["PluginLogoPulse"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
    ],
    targets: [
        .target(
            name: "PluginLogoPulse",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
            ]
        )
    ]
)
