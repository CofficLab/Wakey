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
        .package(url: "https://github.com/CofficLab/LumiKernel.git", from: "1.1.0"),
        .package(url: "https://github.com/CofficLab/LumiUI.git", from: "1.13.1"),
        .package(url: "https://github.com/CofficLab/LumiProviders.git", from: "1.23.0"),
        .package(url: "https://github.com/CofficLab/LumiPluginToast.git", from: "1.2.3"),
        .package(url: "https://github.com/CofficLab/LumiThemePack.git", from: "1.0.12"),
        .package(url: "https://github.com/CofficLab/LumiSettings.git", from: "1.1.0"),
        .package(url: "https://github.com/CofficLab/LumiPluginSettingView.git", from: "1.0.3"),
        .package(path: "../PluginRootView"),
        .package(url: "https://github.com/lumi-softworks/LumiPluginFileLog.git", from: "1.0.0"),
        .package(url: "https://github.com/CofficLab/LumiPluginThemePack.git", from: "1.2.1"),
        // Logo plugins (1)
        .package(path: "../PluginLogoBolt"),
        // Business plugins (4)
        .package(url: "https://github.com/lumi-softworks/LumiPluginCaffeinate.git", from: "1.1.3"),
        .package(url: "https://github.com/lumi-softworks/LumiPluginEyeCareReminder.git", from: "1.0.0"),
        .package(url: "https://github.com/lumi-softworks/LumiPluginStretchReminder.git", from: "1.0.0"),
        .package(url: "https://github.com/CofficLab/LumiPluginHydrationReminder.git", from: "1.0.2"),
        // Other plugins (2)
        // Plugin management (remote package, aligned to Lumi)
        .package(url: "https://github.com/CofficLab/LumiPluginPluginManager.git", from: "1.7.0"),
        // Settings - General (remote package, shared with CofficLab sibling apps)
        .package(url: "https://github.com/lumi-softworks/LumiPluginSettingGeneral.git", from: "1.0.0"),
        // About page (remote package, shared with CofficLab sibling apps)
        .package(url: "https://github.com/CofficLab/LumiPluginAbout.git", from: "3.0.3"),
    ],
    targets: [
        .target(
            name: "FactoryWakey",
            dependencies: [
                .product(name: "ProviderLogo", package: "LumiProviders"),
                .product(name: "ProviderMenuBar", package: "LumiProviders"),
                .product(name: "MenuBarHostKit", package: "LumiProviders"),
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "LumiUI", package: "LumiUI"),
                .product(name: "LumiThemePack", package: "LumiThemePack"),
                .product(name: "ProviderTheme", package: "LumiProviders"),
                .product(name: "ProviderRootView", package: "LumiProviders"),
                .product(name: "ProviderDocsView", package: "LumiProviders"),
                .product(name: "ProviderToast", package: "LumiProviders"),
                .product(name: "ProviderSettingView", package: "LumiSettings"),
                .product(name: "PluginSettingView", package: "LumiPluginSettingView"),
                .product(name: "ProviderPluginControl", package: "LumiProviders"),
                .product(name: "ProviderPluginManaging", package: "LumiProviders"),
                .product(name: "ProviderStorage", package: "LumiProviders"),
                .product(name: "PluginToast", package: "LumiPluginToast"),
                "PluginRootView",
                .product(name: "PluginFileLog", package: "LumiPluginFileLog"),
                .product(name: "PluginThemePack", package: "LumiPluginThemePack"),
                                // Logo
                "PluginLogoBolt",
                // Business
                .product(name: "PluginCaffeinate", package: "LumiPluginCaffeinate"),
                .product(name: "PluginEyeCareReminder", package: "LumiPluginEyeCareReminder"),
                .product(name: "PluginStretchReminder", package: "LumiPluginStretchReminder"),
                .product(name: "PluginHydrationReminder", package: "LumiPluginHydrationReminder"),
                // Other
                // Plugin management (remote package, aligned to Lumi)
                .product(name: "PluginPluginManager", package: "LumiPluginPluginManager"),
                // Settings - General (remote package, shared with CofficLab sibling apps)
                .product(name: "PluginSettingGeneral", package: "LumiPluginSettingGeneral"),
                // About page (remote package, shared with CofficLab sibling apps)
                .product(name: "PluginAbout", package: "LumiPluginAbout"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "FactoryWakeyTests",
            dependencies: [
                "FactoryWakey",
                .product(name: "ProviderSettingView", package: "LumiSettings"),
                .product(name: "ProviderDocsView", package: "LumiProviders"),
                .product(name: "LumiThemePack", package: "LumiThemePack"),
                .product(name: "ProviderTheme", package: "LumiProviders"),
            ]
        )
    ]
)
