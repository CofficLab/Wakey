// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemeVscodeDarkPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ThemeVscodeDarkPlugin", targets: ["ThemeVscodeDarkPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "ThemeVscodeDarkPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
