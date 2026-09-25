// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemeSwitcherPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ThemeSwitcherPlugin", targets: ["ThemeSwitcherPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "ThemeSwitcherPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
