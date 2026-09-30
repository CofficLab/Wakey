// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAppStoreConnect",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginAppStoreConnect", targets: ["PluginAppStoreConnect"])
    ],
    dependencies: [
        .package(path: "../ProviderCopilotNavigation"),
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "PluginAppStoreConnect",
            dependencies: [
                "ProviderCopilotNavigation",
                .product(name: "KernelCore", package: "LumiKernel"),

            ]
        )
    ]
)
