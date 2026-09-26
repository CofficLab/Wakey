// swift-tools-version: 6.0
// ProviderWakeyHost: Wakey 共享 UI 贡献契约层。
import PackageDescription

let package = Package(
    name: "ProviderWakeyHost",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "ProviderWakeyHost", targets: ["ProviderWakeyHost"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(url: "https://github.com/CofficLab/LumiUI.git", from: "1.7.0"),
    ],
    targets: [
        .target(
            name: "ProviderWakeyHost",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "LumiUI", package: "LumiUI"),
            ]
        )
    ]
)
