// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginPurchase",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginPurchase", targets: ["PluginPurchase"])
    ],
    dependencies: [
        .package(path: "../ProviderCopilotNavigation"),
        .package(path: "../KitDesktop"),
        .package(path: "../KitLayout"),
        .package(url: "https://github.com/CofficLab/LumiKernel.git", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "PluginPurchase",
            dependencies: [
                "ProviderCopilotNavigation",
                "KitDesktop",
                "KitLayout",
                .product(name: "KernelCore", package: "LumiKernel"),
            ]
        ),
        .testTarget(
            name: "PluginPurchaseTests",
            dependencies: ["PluginPurchase"]
        ),
    ]
)
