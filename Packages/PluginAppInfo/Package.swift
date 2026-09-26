// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAppInfo",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginAppInfo", targets: ["PluginAppInfo"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
    ],
    targets: [
        .target(
            name: "PluginAppInfo",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
            ]
        )
    ]
)
