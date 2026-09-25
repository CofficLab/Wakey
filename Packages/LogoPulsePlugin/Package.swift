// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LogoPulsePlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "LogoPulsePlugin", targets: ["LogoPulsePlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "LogoPulsePlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
