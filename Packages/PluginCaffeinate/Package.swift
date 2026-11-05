// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PluginCaffeinate",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PluginCaffeinate", targets: ["PluginCaffeinate"])
    ],
    dependencies: [
        .package(path: "../ProviderStatusBarPopup"),
        .package(path: "../KitLogging"),
        .package(url: "https://github.com/CofficLab/LumiSettings.git", from: "1.1.0"),
        .package(url: "https://github.com/CofficLab/LumiKernel.git", from: "1.1.0"),
        .package(url: "https://github.com/CofficLab/LumiUI.git", from: "1.11.1"),
    ],
    targets: [
        .target(
            name: "PluginCaffeinate",
            dependencies: [
                "ProviderStatusBarPopup",
                                "KitLogging",
                .product(name: "ProviderSettingView", package: "LumiSettings"),
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "LumiUI", package: "LumiUI"),


            ],
            resources: [.process("Caffeinate.xcstrings")]
        ),
        .testTarget(
            name: "PluginCaffeinateTests",
            dependencies: ["PluginCaffeinate"]
        ),
    ]
)
