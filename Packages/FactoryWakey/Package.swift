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
        .package(url: "https://github.com/CofficLab/LumiProviders.git", from: "1.5.0"),
        .package(url: "https://github.com/CofficLab/LumiPluginStorage.git", from: "1.0.0"),
        .package(url: "https://github.com/CofficLab/LumiPluginToast.git", from: "1.0.1"),
        .package(url: "https://github.com/CofficLab/LumiThemePack.git", from: "1.0.5"),
        .package(url: "https://github.com/CofficLab/LumiSettings.git", from: "1.0.1"),
        .package(url: "https://github.com/CofficLab/LumiPluginSettingView.git", from: "1.0.2"),
        .package(path: "../ProviderPoster"),
        .package(path: "../ProviderStatusBarPopup"),
        .package(path: "../ProviderCopilotNavigation"),
        .package(path: "../KitBackground"),
        .package(path: "../KitDesktop"),
        .package(path: "../KitLogging"),
        .package(path: "../KitLayout"),
        .package(path: "../PluginRootView"),
        .package(url: "https://github.com/CofficLab/LumiPluginThemePack.git", from: "1.1.0"),
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
        // Plugin management (aligned to Lumi)
        .package(path: "../PluginPluginManager"),
        // Settings - General (aligned to Lumi)
        .package(path: "../PluginSettingGeneral"),
        // Onboarding (aligned to Lumi)
        .package(path: "../PluginOnboarding"),
        .package(path: "../PluginWelcome"),
    ],
    targets: [
        .target(
            name: "FactoryWakey",
            dependencies: [
                .product(name: "ProviderLogo", package: "LumiProviders"),
                "ProviderPoster",
                "ProviderStatusBarPopup",
                "ProviderCopilotNavigation",
                "KitBackground",
                "KitDesktop",
                "KitLogging",
                "KitLayout",
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "LumiUI", package: "LumiUI"),
                .product(name: "LumiThemePack", package: "LumiThemePack"),
                .product(name: "ProviderTheme", package: "LumiProviders"),
                .product(name: "ProviderRootView", package: "LumiProviders"),
                .product(name: "ProviderToast", package: "LumiProviders"),
                .product(name: "ProviderSettingView", package: "LumiSettings"),
                .product(name: "PluginSettingView", package: "LumiPluginSettingView"),
                .product(name: "ProviderPluginControl", package: "LumiProviders"),
                .product(name: "ProviderPluginManaging", package: "LumiProviders"),
                .product(name: "ProviderStorage", package: "LumiProviders"),
                .product(name: "PluginToast", package: "LumiPluginToast"),
                .product(name: "PluginStorage", package: "LumiPluginStorage"),
                                "PluginRootView",
                .product(name: "PluginThemePack", package: "LumiPluginThemePack"),
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
                // Plugin management (aligned to Lumi)
                "PluginPluginManager",
                // Settings - General (aligned to Lumi)
                "PluginSettingGeneral",
                // Onboarding (aligned to Lumi)
                "PluginOnboarding", "PluginWelcome",
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "FactoryWakeyTests",
            dependencies: ["FactoryWakey"]
        )
    ]
)
