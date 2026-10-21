// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ProviderAppUninstall",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ProviderAppUninstall",
            targets: ["ProviderAppUninstall"]
        ),
    ],
    targets: [
        .target(
            name: "ProviderAppUninstall",
            path: "Sources/ProviderAppUninstall"
        ),
        .testTarget(
            name: "ProviderAppUninstallTests",
            dependencies: ["ProviderAppUninstall"],
            path: "Tests/ProviderAppUninstallTests"
        )
    ]
)
