// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginPosterStretch",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginPosterStretch", targets: ["PluginPosterStretch"])
    ],
    dependencies: [
        .package(path: "../ProviderPoster"),
        .package(path: "../KitLayout"),
        .package(url: "https://github.com/CofficLab/LumiKernel.git", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "PluginPosterStretch",
            dependencies: [
                "ProviderPoster",
                "KitLayout",
                .product(name: "KernelCore", package: "LumiKernel"),


            ]
        ),
        .testTarget(
            name: "PluginPosterStretchTests",
            dependencies: ["PluginPosterStretch"]
        ),
    ]
)
