// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginPosterStretch",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginPosterStretch", targets: ["PluginPosterStretch"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
        .package(path: "../MagicKit"),
    ],
    targets: [
        .target(
            name: "PluginPosterStretch",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
                "MagicKit",
            ]
        )
    ]
)
