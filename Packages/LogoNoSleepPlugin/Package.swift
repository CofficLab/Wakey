// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LogoNoSleepPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "LogoNoSleepPlugin", targets: ["LogoNoSleepPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "LogoNoSleepPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
