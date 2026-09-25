// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemeVscodeLightPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ThemeVscodeLightPlugin", targets: ["ThemeVscodeLightPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "ThemeVscodeLightPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
