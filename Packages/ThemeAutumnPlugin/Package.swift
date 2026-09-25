// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemeAutumnPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ThemeAutumnPlugin", targets: ["ThemeAutumnPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "ThemeAutumnPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
