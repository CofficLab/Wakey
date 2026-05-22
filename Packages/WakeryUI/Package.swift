// swift-tools-version: 6.0
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
        ),
        .testTarget(
            name: "WakeryUITests",
            dependencies: ["WakeryUI"],
            path: "Tests/WakeryUITests"
        )
    ]
)
