// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginPosterWakey",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginPosterWakey", targets: ["PluginPosterWakey"])
    ],
    dependencies: [
        .package(path: "../ProviderPoster"),
        .package(path: "../KitLayout"),
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "PluginPosterWakey",
            dependencies: [
                "ProviderPoster",
                "KitLayout",
                .product(name: "KernelCore", package: "LumiKernel"),


            ]
        )
    ]
)
