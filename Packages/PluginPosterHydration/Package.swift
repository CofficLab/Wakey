// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginPosterHydration",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginPosterHydration", targets: ["PluginPosterHydration"])
    ],
    dependencies: [
        .package(path: "../ProviderPoster"),
        .package(path: "../KitLayout"),
        .package(url: "https://github.com/CofficLab/LumiKernel.git", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "PluginPosterHydration",
            dependencies: [
                "ProviderPoster",
                "KitLayout",
                .product(name: "KernelCore", package: "LumiKernel"),


            ]
        ),
        .testTarget(
            name: "PluginPosterHydrationTests",
            dependencies: ["PluginPosterHydration"]
        ),
    ]
)
