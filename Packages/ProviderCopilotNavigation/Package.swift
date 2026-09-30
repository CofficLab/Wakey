// swift-tools-version: 6.0
// ProviderCopilotNavigation: 导航项贡献契约层（对齐 Lumi Provider 模式）。
import PackageDescription

let package = Package(
    name: "ProviderCopilotNavigation",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ProviderCopilotNavigation", targets: ["ProviderCopilotNavigation"]),
    ],
    targets: [
        .target(name: "ProviderCopilotNavigation"),
    ]
)
