// swift-tools-version: 6.0
// KitBackground: 背景动画与渐变色系统（对齐 Lumi Kit 模式）。
import PackageDescription

let package = Package(
    name: "KitBackground",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "KitBackground", targets: ["KitBackground"]),
    ],
    targets: [
        .target(name: "KitBackground"),
    ]
)
