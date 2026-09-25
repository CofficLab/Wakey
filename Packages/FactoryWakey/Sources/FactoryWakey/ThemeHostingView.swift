import Combine
import Foundation
import LumiUI
import ProviderTheme
import SwiftUI

/// Bridges Wakey's Lumi `ProviderTheme` selection into LumiUI before each
/// window is rendered, matching FactoryLumi's theme-hosting behavior.
@MainActor
enum ThemeSynchronizer {
    static func sync(_ provider: any ProviderTheme.ThemeProviding) {
        guard let selected = provider.selectedTheme else { return }

        let colorScheme: ColorScheme
        switch selected.appearanceKind {
        case .dark:
            colorScheme = .dark
        case .light:
            colorScheme = .light
        case .system:
            colorScheme = SystemAppearanceResolver.effectiveColorScheme
        }

        ResolvedSystemColorScheme.current = colorScheme
        let chrome = PaletteChromeTheme(theme: selected, colorScheme: colorScheme)
        ActiveChromeTheme.current = chrome
        LumiUIThemeStore.shared.setTheme(ChromeToUIThemeAdapter(chrome: chrome))
        ThemeWindowAppearanceSync.syncAllWindows()
    }
}

@MainActor
struct ThemeHostingView<Content: View>: View {
    let theme: any ProviderTheme.ThemeProviding
    let content: Content

    @StateObject private var observation: ThemeObservation
    @State private var refreshTick = false

    init(theme: any ProviderTheme.ThemeProviding, content: Content) {
        self.theme = theme
        self.content = content
        _observation = StateObject(wrappedValue: ThemeObservation(theme: theme))
    }

    var body: some View {
        let _ = refreshTick

        content
            .preferredColorScheme(preferredColorScheme)
            .background(backgroundColor)
            .onAppear { ThemeSynchronizer.sync(theme) }
            .onReceive(observation.$revision) { _ in
                refreshTick.toggle()
                ThemeSynchronizer.sync(theme)
            }
        #if os(macOS)
            .onReceive(
                DistributedNotificationCenter.default().publisher(
                    for: Notification.Name("AppleInterfaceThemeChangedNotification")
                )
                .receive(on: RunLoop.main)
            ) { _ in
                guard theme.followsSystemAppearance else { return }
                refreshTick.toggle()
                ThemeSynchronizer.sync(theme)
            }
        #endif
    }

    private var preferredColorScheme: ColorScheme? {
        switch theme.selectedTheme?.appearanceKind ?? .system {
        case .dark: .dark
        case .light: .light
        case .system: ResolvedSystemColorScheme.current
        }
    }

    private var backgroundColor: Color {
        guard let selected = theme.selectedTheme else {
            return Color(nsColor: .windowBackgroundColor)
        }
        let colorScheme = preferredColorScheme ?? SystemAppearanceResolver.effectiveColorScheme
        return selected.palette.backgroundMedium.color(colorScheme: colorScheme)
    }
}

@MainActor
private final class ThemeObservation: ObservableObject {
    @Published private(set) var revision = 0
    private var handle: (any ProviderTheme.ThemeProvidingObserverHandle)?

    init(theme: any ProviderTheme.ThemeProviding) {
        handle = theme.addObserver { [weak self] _ in
            self?.revision += 1
        }
    }
}
