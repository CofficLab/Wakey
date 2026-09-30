// swift-tools-version: 6.0
// ProviderStatusBarPopup: 状态栏弹窗贡献契约层（对齐 Lumi Provider 模式）。
import PackageDescription

let package = Package(
    name: "ProviderStatusBarPopup",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "ProviderStatusBarPopup", targets: ["ProviderStatusBarPopup"]),
    ],
    targets: [
        .target(name: "ProviderStatusBarPopup"),
    ]
)
