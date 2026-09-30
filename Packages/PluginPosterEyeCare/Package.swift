// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginPosterEyeCare",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginPosterEyeCare", targets: ["PluginPosterEyeCare"])
    ],
    dependencies: [
        .package(path: "../ProviderPoster"),
        .package(path: "../KitLayout"),
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "PluginPosterEyeCare",
            dependencies: [
                "ProviderPoster",
                "KitLayout",
                .product(name: "KernelCore", package: "LumiKernel"),


            ]
        )
    ]
)
