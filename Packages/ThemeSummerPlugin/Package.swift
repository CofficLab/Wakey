// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ThemeSummerPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ThemeSummerPlugin", targets: ["ThemeSummerPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "ThemeSummerPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
