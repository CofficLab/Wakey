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
        .package(url: "https://github.com/CofficLab/LumiUI.git", from: "1.0.1"),
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../ProviderTheme"),
        .package(path: "../PluginThemePack"),
        .package(path: "../WakeryUI"),
        .package(path: "../MagicKit"),
        // Logo plugins (11)
        .package(path: "../PluginLogoBolt"),
        .package(path: "../PluginLogoLightBulb"),
        .package(path: "../PluginLogoOwl"),
        .package(path: "../PluginLogoCoffee"),
        .package(path: "../PluginLogoSun"),
        .package(path: "../PluginLogoBattery"),
        .package(path: "../PluginLogoMoon"),
        .package(path: "../PluginLogoNoSleep"),
        .package(path: "../PluginLogoRadar"),
        .package(path: "../PluginLogoPulse"),
        .package(path: "../PluginLogoPreview"),
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
                "ProviderWakeyHost",
                "ProviderTheme",
                "PluginThemePack",
                "WakeryUI",
                "MagicKit",
                // Logo
                "PluginLogoBolt", "PluginLogoLightBulb", "PluginLogoOwl",
                "PluginLogoCoffee", "PluginLogoSun", "PluginLogoBattery",
                "PluginLogoMoon", "PluginLogoNoSleep", "PluginLogoRadar",
                "PluginLogoPulse", "PluginLogoPreview",
                // Poster
                "PluginPosterWakey", "PluginPosterCaffeinate", "PluginPosterEyeCare",
                "PluginPosterStretch", "PluginPosterHydration", "PluginPosterPreview",
                // Business
                "PluginCaffeinate", "PluginEyeCareReminder",
                "PluginStretchReminder", "PluginHydrationReminder",
                // Other
                "PluginAppInfo", "PluginAppStoreConnect", "PluginPurchase",
            ]
        )
    ]
)
