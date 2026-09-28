// swift-tools-version: 6.0
// FactoryWakey: Wakey 唯一静态装配点（Composition Root）。
import PackageDescription

let package = Package(
    name: "FactoryWakey",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "FactoryWakey", targets: ["FactoryWakey"])
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", branch: "main"),
        .package(url: "https://github.com/CofficLab/LumiUI.git", from: "1.7.0"),
        .package(url: "https://github.com/CofficLab/LumiProviders.git", from: "1.2.2"),
        .package(url: "https://github.com/CofficLab/LumiThemePack.git", from: "1.0.4"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../PluginThemePack"),
        .package(path: "../MagicKit"),
        // Logo plugins (1)
        .package(path: "../PluginLogoBolt"),
        // Poster plugins (6)
        .package(path: "../PluginPosterWakey"),
        .package(path: "../PluginPosterCaffeinate"),
        .package(path: "../PluginPosterEyeCare"),
        .package(path: "../PluginPosterStretch"),
        .package(path: "../PluginPosterHydration"),
        .package(path: "../PluginPosterPreview"),
        // Business plugins (4)
        .package(path: "../PluginCaffeinate"),
        .package(path: "../PluginEyeCareReminder"),
        .package(path: "../PluginStretchReminder"),
        .package(path: "../PluginHydrationReminder"),
        // Other plugins (3)
        .package(path: "../PluginAppInfo"),
        .package(path: "../PluginAppStoreConnect"),
        .package(path: "../PluginPurchase"),
    ],
    targets: [
        .target(
            name: "FactoryWakey",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "LumiUI", package: "LumiUI"),
                .product(name: "LumiThemePack", package: "LumiThemePack"),
                .product(name: "ProviderTheme", package: "LumiProviders"),
                "ProviderWakeyHost",
                "PluginThemePack",
                "MagicKit",
                // Logo
                "PluginLogoBolt",
                // Poster
                "PluginPosterWakey", "PluginPosterCaffeinate", "PluginPosterEyeCare",
                "PluginPosterStretch", "PluginPosterHydration", "PluginPosterPreview",
                // Business
                "PluginCaffeinate", "PluginEyeCareReminder",
                "PluginStretchReminder", "PluginHydrationReminder",
                // Other
                "PluginAppInfo", "PluginAppStoreConnect", "PluginPurchase",
            ]
        ),
        .testTarget(
            name: "FactoryWakeyTests",
            dependencies: ["FactoryWakey"]
        )
    ]
)
