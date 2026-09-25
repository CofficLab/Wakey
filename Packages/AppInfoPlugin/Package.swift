// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppInfoPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "AppInfoPlugin", targets: ["AppInfoPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "AppInfoPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
