// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemeAuroraPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ThemeAuroraPlugin", targets: ["ThemeAuroraPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "ThemeAuroraPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
