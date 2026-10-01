// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginPosterPreview",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginPosterPreview", targets: ["PluginPosterPreview"])
    ],
    dependencies: [
        .package(path: "../ProviderPoster"),
        .package(path: "../ProviderCopilotNavigation"),
        .package(path: "../KitLogging"),
        .package(path: "../KitLayout"),
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "PluginPosterPreview",
            dependencies: [
                "ProviderPoster",
                "ProviderCopilotNavigation",
                "KitLogging",
                "KitLayout",
                .product(name: "KernelCore", package: "LumiKernel"),
            ]
        )
    ]
)
