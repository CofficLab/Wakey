// swift-tools-version: 6.0
// KitDesktop: 模拟 macOS 桌面视图（顶部菜单栏 + Dock + 内容）。
import PackageDescription

let package = Package(
    name: "KitDesktop",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "KitDesktop", targets: ["KitDesktop"]),
    ],
    dependencies: [
        .package(path: "../KitBackground"),
    ],
    targets: [
        .target(
            name: "KitDesktop",
            dependencies: ["KitBackground"],
            resources: [.process("Icons.xcassets")],
        ),
    ]
)
