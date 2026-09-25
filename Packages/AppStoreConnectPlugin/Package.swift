// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppStoreConnectPlugin",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "AppStoreConnectPlugin", targets: ["AppStoreConnectPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
    ],
    targets: [
        .target(
            name: "AppStoreConnectPlugin",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
            ]
        )
    ]
)
