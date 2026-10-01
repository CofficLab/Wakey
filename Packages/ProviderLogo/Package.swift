// swift-tools-version: 6.0
// ProviderLogo: Logo 贡献契约层（对齐 Lumi Provider 模式）。
import PackageDescription

let package = Package(
    name: "ProviderLogo",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ProviderLogo", targets: ["ProviderLogo"]),
    ],
    targets: [
        .target(name: "ProviderLogo"),
    ]
)
