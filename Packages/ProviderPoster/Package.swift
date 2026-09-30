// swift-tools-version: 6.0
// ProviderPoster: Poster 视图贡献契约层（对齐 Lumi Provider 模式）。
import PackageDescription

let package = Package(
    name: "ProviderPoster",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ProviderPoster", targets: ["ProviderPoster"]),
    ],
    targets: [
        .target(name: "ProviderPoster"),
    ]
)
