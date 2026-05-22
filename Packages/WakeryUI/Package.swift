// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WakeryUI",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "WakeryUI",
            targets: ["WakeryUI"]
        )
    ],
    targets: [
        .target(
            name: "WakeryUI",
            path: "Sources/WakeryUI"
        )
    ]
)
