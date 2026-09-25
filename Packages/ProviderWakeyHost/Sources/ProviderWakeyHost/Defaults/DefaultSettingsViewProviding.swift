import SwiftUI

/// `SettingsViewProviding` 默认实现。
@MainActor
public final class DefaultSettingsViewProviding: SettingsViewProviding {
    private var entries: [(ownerID: String, item: SettingsTabItem)] = []

    public var settingsTabs: [SettingsTabItem] { entries.map(\.item) }

    public init() {}

    public func addSettingsTab(ownerID: String, _ item: SettingsTabItem) {
        entries.append((ownerID, item))
    }

    public func removeSettingsTabs(ownerID: String) {
        entries.removeAll { $0.ownerID == ownerID }
    }
}
