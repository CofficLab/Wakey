// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAppStoreConnect",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginAppStoreConnect", targets: ["PluginAppStoreConnect"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "PluginAppStoreConnect",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
