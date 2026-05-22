internal import Combine
import Foundation
import SwiftUI
import WakeryUI

@MainActor
final class AppThemeVM: ObservableObject {
    private enum Defaults {
        static let selectedThemeId = "wakey.selectedThemeId"
    }

    @Published private(set) var themes: [WakeryUIThemeContribution] = []
    @Published private(set) var currentThemeId: String?

    var currentTheme: WakeryUIThemeContribution? {
        themes.first { $0.id == currentThemeId }
    }

    init(pluginProvider: PluginProvider) {
        reload(from: pluginProvider)
    }

    func reload(from pluginProvider: PluginProvider) {
        let contributions = pluginProvider.getThemeContributions()
        guard !contributions.isEmpty else { return }

        do {
            try WakeryUIThemeRegistry.shared.replaceAll(contributions)
            themes = WakeryUIThemeRegistry.shared.themes

            let savedId = UserDefaults.standard.string(forKey: Defaults.selectedThemeId)
            if let savedId, themes.contains(where: { $0.id == savedId }) {
                selectTheme(savedId)
            } else if let defaultId = WakeryUIThemeRegistry.shared.selectedThemeId {
                currentThemeId = defaultId
            }
        } catch {
            assertionFailure("Failed to register themes: \(error)")
        }
    }

    func selectTheme(_ id: String) {
        do {
            try WakeryUIThemeRegistry.shared.select(themeId: id)
            currentThemeId = id
            UserDefaults.standard.set(id, forKey: Defaults.selectedThemeId)
        } catch {
            assertionFailure("Failed to select theme '\(id)': \(error)")
        }
    }
}
