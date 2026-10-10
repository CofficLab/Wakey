// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginLogoBolt",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginLogoBolt", targets: ["PluginLogoBolt"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(url: "https://github.com/CofficLab/LumiProviders.git", from: "1.5.0"),
    ],
    targets: [
        .target(
            name: "PluginLogoBolt",
            dependencies: [
                .product(name: "ProviderLogo", package: "LumiProviders"),
                .product(name: "KernelCore", package: "LumiKernel"),

            ]
        )
    ]
)
