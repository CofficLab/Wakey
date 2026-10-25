// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginAppInfo",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginAppInfo", targets: ["PluginAppInfo"])
    ],
    dependencies: [
        .package(path: "../ProviderCopilotNavigation"),
        .package(url: "https://github.com/CofficLab/LumiKernel.git", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "PluginAppInfo",
            dependencies: [
                "ProviderCopilotNavigation",
                .product(name: "KernelCore", package: "LumiKernel"),

            ]
        ),
        .testTarget(
            name: "PluginAppInfoTests",
            dependencies: ["PluginAppInfo"]
        ),
    ]
)
