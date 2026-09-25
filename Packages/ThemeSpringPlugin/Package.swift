// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemeSpringPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ThemeSpringPlugin", targets: ["ThemeSpringPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "ThemeSpringPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
