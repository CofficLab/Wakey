// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LogoMoonPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "LogoMoonPlugin", targets: ["LogoMoonPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "LogoMoonPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
