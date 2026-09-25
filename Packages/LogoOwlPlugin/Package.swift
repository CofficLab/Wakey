// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LogoOwlPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "LogoOwlPlugin", targets: ["LogoOwlPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "LogoOwlPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
