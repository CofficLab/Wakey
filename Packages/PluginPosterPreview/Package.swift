// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginPosterPreview",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginPosterPreview", targets: ["PluginPosterPreview"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../MagicKit"),
    ],
    targets: [
        .target(
            name: "PluginPosterPreview",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "MagicKit",
            ]
        )
    ]
)
