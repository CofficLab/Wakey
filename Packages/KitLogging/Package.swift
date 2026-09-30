// swift-tools-version: 6.0
// KitLogging: 统一日志协议 SuperLog 及字符串 Emoji 扩展。
import PackageDescription

let package = Package(
    name: "KitLogging",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "KitLogging", targets: ["KitLogging"]),
    ],
    targets: [
        .target(name: "KitLogging"),
    ]
)
