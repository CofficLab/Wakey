// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginPosterWakey",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginPosterWakey", targets: ["PluginPosterWakey"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
        .package(path: "../MagicKit"),
    ],
    targets: [
        .target(
            name: "PluginPosterWakey",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
                "MagicKit",
            ]
        )
    ]
)
