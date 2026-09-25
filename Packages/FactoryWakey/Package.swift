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
        .package(path: "../ProviderWakeyHost"),
        .package(path: "../WakeryUI"),
        .package(path: "../MagicKit"),
        // Logo plugins (11)
        .package(path: "../LogoBoltPlugin"),
        .package(path: "../LogoLightBulbPlugin"),
        .package(path: "../LogoOwlPlugin"),
        .package(path: "../LogoCoffeePlugin"),
        .package(path: "../LogoSunPlugin"),
        .package(path: "../LogoBatteryPlugin"),
        .package(path: "../LogoMoonPlugin"),
        .package(path: "../LogoNoSleepPlugin"),
        .package(path: "../LogoRadarPlugin"),
        .package(path: "../LogoPulsePlugin"),
        .package(path: "../LogoPreviewPlugin"),
        // Poster plugins (6)
        .package(path: "../PosterWakeyPlugin"),
        .package(path: "../PosterCaffeinatePlugin"),
        .package(path: "../PosterEyeCarePlugin"),
        .package(path: "../PosterStretchPlugin"),
        .package(path: "../PosterHydrationPlugin"),
        .package(path: "../PosterPreviewPlugin"),
        // Business plugins (4)
        .package(path: "../CaffeinatePlugin"),
        .package(path: "../EyeCareReminderPlugin"),
        .package(path: "../StretchReminderPlugin"),
        .package(path: "../HydrationReminderPlugin"),
        // Other plugins (3)
        .package(path: "../AppInfoPlugin"),
        .package(path: "../AppStoreConnectPlugin"),
        .package(path: "../PurchasePlugin"),
        // Theme plugins (13)
        .package(path: "../ThemeSwitcherPlugin"),
        .package(path: "../ThemeWakeyPlugin"),
        .package(path: "../ThemeAuroraPlugin"),
        .package(path: "../ThemeDraculaPlugin"),
        .package(path: "../ThemeGithubPlugin"),
        .package(path: "../ThemeOneDarkPlugin"),
        .package(path: "../ThemeVscodeDarkPlugin"),
        .package(path: "../ThemeVscodeLightPlugin"),
        .package(path: "../ThemeSpringPlugin"),
        .package(path: "../ThemeSummerPlugin"),
        .package(path: "../ThemeAutumnPlugin"),
        .package(path: "../ThemeWinterPlugin"),
        .package(path: "../ThemeRiverPlugin"),
    ],
    targets: [
        .target(
            name: "FactoryWakey",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                "ProviderWakeyHost",
                "WakeryUI",
                "MagicKit",
                // Logo
                "LogoBoltPlugin", "LogoLightBulbPlugin", "LogoOwlPlugin",
                "LogoCoffeePlugin", "LogoSunPlugin", "LogoBatteryPlugin",
                "LogoMoonPlugin", "LogoNoSleepPlugin", "LogoRadarPlugin",
                "LogoPulsePlugin", "LogoPreviewPlugin",
                // Poster
                "PosterWakeyPlugin", "PosterCaffeinatePlugin", "PosterEyeCarePlugin",
                "PosterStretchPlugin", "PosterHydrationPlugin", "PosterPreviewPlugin",
                // Business
                "CaffeinatePlugin", "EyeCareReminderPlugin",
                "StretchReminderPlugin", "HydrationReminderPlugin",
                // Other
                "AppInfoPlugin", "AppStoreConnectPlugin", "PurchasePlugin",
                // Theme
                "ThemeSwitcherPlugin", "ThemeWakeyPlugin", "ThemeAuroraPlugin",
                "ThemeDraculaPlugin", "ThemeGithubPlugin", "ThemeOneDarkPlugin",
                "ThemeVscodeDarkPlugin", "ThemeVscodeLightPlugin",
                "ThemeSpringPlugin", "ThemeSummerPlugin", "ThemeAutumnPlugin",
                "ThemeWinterPlugin", "ThemeRiverPlugin",
            ]
        )
    ]
)
