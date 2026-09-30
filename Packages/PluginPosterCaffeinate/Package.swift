// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginPosterCaffeinate",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginPosterCaffeinate", targets: ["PluginPosterCaffeinate"])
    ],
    dependencies: [
        .package(path: "../ProviderPoster"),
        .package(path: "../KitLayout"),
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "PluginPosterCaffeinate",
            dependencies: [
                "ProviderPoster",
                "KitLayout",
                .product(name: "KernelCore", package: "LumiKernel"),


            ]
        )
    ]
)
