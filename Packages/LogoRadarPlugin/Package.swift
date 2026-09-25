// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LogoRadarPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "LogoRadarPlugin", targets: ["LogoRadarPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "LogoRadarPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
