// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemeWinterPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ThemeWinterPlugin", targets: ["ThemeWinterPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "ThemeWinterPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
