// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LogoSunPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "LogoSunPlugin", targets: ["LogoSunPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "LogoSunPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
