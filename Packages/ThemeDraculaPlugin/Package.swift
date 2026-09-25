// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemeDraculaPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ThemeDraculaPlugin", targets: ["ThemeDraculaPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "ThemeDraculaPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
