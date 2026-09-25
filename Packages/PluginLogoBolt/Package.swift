// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginLogoBolt",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginLogoBolt", targets: ["PluginLogoBolt"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "PluginLogoBolt",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
