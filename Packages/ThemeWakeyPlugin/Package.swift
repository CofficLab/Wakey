// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemeWakeyPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ThemeWakeyPlugin", targets: ["ThemeWakeyPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "ThemeWakeyPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
