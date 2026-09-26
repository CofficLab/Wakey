// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginLogoPreview",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginLogoPreview", targets: ["PluginLogoPreview"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
    ],
    targets: [
        .target(
            name: "PluginLogoPreview",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
            ]
        )
    ]
)
