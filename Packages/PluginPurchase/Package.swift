// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginPurchase",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginPurchase", targets: ["PluginPurchase"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
        .package(path: "../MagicKit"),
    ],
    targets: [
        .target(
            name: "PluginPurchase",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
                "MagicKit",
            ]
        )
    ]
)
