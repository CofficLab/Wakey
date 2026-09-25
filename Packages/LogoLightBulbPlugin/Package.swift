// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LogoLightBulbPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "LogoLightBulbPlugin", targets: ["LogoLightBulbPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "LogoLightBulbPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
