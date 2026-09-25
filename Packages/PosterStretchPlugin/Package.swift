// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PosterStretchPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PosterStretchPlugin", targets: ["PosterStretchPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
        .package(path: "../MagicKit"),
    ],
    targets: [
        .target(
            name: "PosterStretchPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
                "MagicKit",
            ]
        )
    ]
)
