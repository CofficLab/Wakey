// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LogoBoltPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "LogoBoltPlugin", targets: ["LogoBoltPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "LogoBoltPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
