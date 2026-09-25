// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemeRiverPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ThemeRiverPlugin", targets: ["ThemeRiverPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "ThemeRiverPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
