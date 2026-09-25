import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

private struct AppThemedAppearanceModifier: ViewModifier {
    @ObservedObject private var registry = WakeryUIThemeRegistry.shared

    func body(content: Content) -> some View {
        content.preferredColorScheme(preferredColorScheme)
    }

    private var preferredColorScheme: ColorScheme? {
        let chromeTheme = registry.chromeTheme
        guard !chromeTheme.followsSystemAppearance else { return nil }
        return chromeTheme.isDarkTheme ? .dark : .light
    }
}

public extension View {
    /// Keeps SwiftUI controls aligned with the selected Wakery chrome theme.
    func appThemedAppearance() -> some View {
        modifier(AppThemedAppearanceModifier())
    }
}

#if canImport(AppKit)
/// Synchronizes the hosting NSWindow with the selected Wakery theme so AppKit
/// controls use the same light or dark appearance as the SwiftUI settings shell.
public struct ThemeWindowAppearanceBridge: NSViewRepresentable {
    @ObservedObject private var registry = WakeryUIThemeRegistry.shared

    public init() {}

    public func makeNSView(context: Context) -> NSView {
        let view = ThemeWindowAppearanceHostView()
        view.applyAppearance(from: registry.chromeTheme)
        return view
    }

    public func updateNSView(_ nsView: NSView, context: Context) {
        (nsView as? ThemeWindowAppearanceHostView)?.applyAppearance(from: registry.chromeTheme)
    }
}

private final class ThemeWindowAppearanceHostView: NSView {
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        applyAppearance(from: WakeryUIThemeRegistry.shared.chromeTheme)
    }

    func applyAppearance(from theme: any WakeryAppChromeTheme) {
        guard let window else { return }
        guard !theme.followsSystemAppearance else {
            window.appearance = nil
            return
        }
        window.appearance = NSAppearance(named: theme.isDarkTheme ? .darkAqua : .aqua)
    }
}
#endif
