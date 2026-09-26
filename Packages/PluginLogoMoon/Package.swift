// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginLogoMoon",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginLogoMoon", targets: ["PluginLogoMoon"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
    ],
    targets: [
        .target(
            name: "PluginLogoMoon",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
            ]
        )
    ]
)
