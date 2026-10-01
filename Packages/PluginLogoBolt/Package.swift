// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginLogoBolt",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginLogoBolt", targets: ["PluginLogoBolt"])
    ],
    dependencies: [
        .package(path: "../ProviderLogo"),
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "PluginLogoBolt",
            dependencies: [
                "ProviderLogo",
                .product(name: "KernelCore", package: "LumiKernel"),

            ]
        )
    ]
)
