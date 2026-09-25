// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LogoPreviewPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "LogoPreviewPlugin", targets: ["LogoPreviewPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "LogoPreviewPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
