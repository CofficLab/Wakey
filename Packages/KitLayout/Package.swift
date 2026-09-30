// swift-tools-version: 6.0
// KitLayout: 布局便捷扩展（居中 VStack 等）。
import PackageDescription

let package = Package(
    name: "KitLayout",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "KitLayout", targets: ["KitLayout"]),
    ],
    targets: [
        .target(name: "KitLayout"),
    ]
)
