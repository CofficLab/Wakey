// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginRootView",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginRootView", targets: ["PluginRootView"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", from: "1.1.0"),
        .package(url: "https://github.com/CofficLab/LumiProviders.git", from: "1.13.0"),
    ],
    targets: [
        .target(
            name: "PluginRootView",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "ProviderRootView", package: "LumiProviders"),
            ]
        ),
        .testTarget(
            name: "PluginRootViewTests",
            dependencies: [
                "PluginRootView",
                .product(name: "ProviderRootView", package: "LumiProviders"),
            ]
        ),
    ]
)
