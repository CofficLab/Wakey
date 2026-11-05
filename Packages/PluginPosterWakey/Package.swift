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
        .package(url: "https://github.com/CofficLab/LumiKernel.git", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "PluginPosterWakey",
            dependencies: [
                "ProviderPoster",
                "KitLayout",
                .product(name: "KernelCore", package: "LumiKernel"),


            ]
        ),
        .testTarget(
            name: "PluginPosterWakeyTests",
            dependencies: ["PluginPosterWakey"]
        ),
    ]
)
