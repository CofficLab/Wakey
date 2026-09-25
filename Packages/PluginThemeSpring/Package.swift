// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginThemeSpring",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginThemeSpring", targets: ["PluginThemeSpring"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "PluginThemeSpring",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
