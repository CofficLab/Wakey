import Foundation
import SwiftUI
import WakeryUI

protocol ThemeContributionPlugin: SuperPlugin {
    static var themeIdentifier: String { get }
    static var themeDisplayName: String { get }
    static var themeDescription: String { get }
    static var themeIconName: String { get }
    static var themeOrder: Int { get }

    @MainActor static func makeAppTheme() -> any WakeryAppChromeTheme
}

extension ThemeContributionPlugin {
    static var id: String { themeIdentifier }
    static var displayName: String { themeDisplayName }
    static var description: String { themeDescription }
    static var iconName: String { themeIconName }
    static var isConfigurable: Bool { false }
    static var order: Int { themeOrder }

    nonisolated var instanceLabel: String { Self.id }

    @MainActor
    func addThemeContributions() -> [WakeryUIThemeContribution] {
        let appTheme = Self.makeAppTheme()
        return [
            WakeryUIThemeContribution(
                appTheme: appTheme,
                editorThemeId: appTheme.identifier
            ),
        ]
    }
}
