// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeWinter",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginThemeWinter", targets: ["PluginThemeWinter"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "PluginThemeWinter",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
