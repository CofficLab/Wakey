// swift-tools-version: 6.0
// ProviderSettingsView: 设置界面贡献契约层（对齐 Lumi Provider 模式）。
import PackageDescription

let package = Package(
    name: "ProviderSettingsView",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ProviderSettingsView", targets: ["ProviderSettingsView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(url: "https://github.com/CofficLab/LumiUI.git", from: "1.7.0"),
    ],
    targets: [
        .target(
            name: "ProviderSettingsView",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "LumiUI", package: "LumiUI"),
            ]
        ),
    ]
)
