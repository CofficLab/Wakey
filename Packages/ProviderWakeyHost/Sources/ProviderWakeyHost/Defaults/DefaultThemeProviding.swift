import Foundation
import SwiftUI
import WakeryUI

/// `ThemeProviding` 默认实现（替代原 AppThemeVM）。
@MainActor
public final class DefaultThemeProviding: ThemeProviding {
    private enum Defaults {
        static let selectedThemeId = "wakey.selectedThemeId"
    }

    private var entries: [(ownerID: String, contribution: WakeryUIThemeContribution)] = []
    private(set) public var currentThemeId: String?

    public var themes: [WakeryUIThemeContribution] { entries.map(\.contribution) }

    public init() {}

    public func addTheme(ownerID: String, _ contribution: WakeryUIThemeContribution) {
        entries.append((ownerID, contribution))
        syncToRegistry()
    }

    public func selectTheme(_ id: String) {
        guard themes.contains(where: { $0.id == id }) else { return }
        currentThemeId = id
        UserDefaults.standard.set(id, forKey: Defaults.selectedThemeId)
        do {
            try WakeryUIThemeRegistry.shared.select(themeId: id)
        } catch {
            // 主题选择失败不崩溃
        }
    }

    public func removeThemes(ownerID: String) {
        entries.removeAll { $0.ownerID == ownerID }
        syncToRegistry()
        if let currentId = currentThemeId, !themes.contains(where: { $0.id == currentId }) {
            currentThemeId = themes.first?.id
            if let id = currentThemeId {
                UserDefaults.standard.set(id, forKey: Defaults.selectedThemeId)
            }
        }
    }

    private func syncToRegistry() {
        let contributions = themes
        guard !contributions.isEmpty else { return }
        do {
            try WakeryUIThemeRegistry.shared.replaceAll(contributions)
            let savedId = UserDefaults.standard.string(forKey: Defaults.selectedThemeId)
            if let savedId, contributions.contains(where: { $0.id == savedId }) {
                currentThemeId = savedId
                try WakeryUIThemeRegistry.shared.select(themeId: savedId)
            } else if let defaultId = WakeryUIThemeRegistry.shared.selectedThemeId {
                currentThemeId = defaultId
            }
        } catch {
            // 注册表同步失败不崩溃
        }
    }
}
