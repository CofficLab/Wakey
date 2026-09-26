// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginLogoCoffee",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginLogoCoffee", targets: ["PluginLogoCoffee"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
    ],
    targets: [
        .target(
            name: "PluginLogoCoffee",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
            ]
        )
    ]
)
