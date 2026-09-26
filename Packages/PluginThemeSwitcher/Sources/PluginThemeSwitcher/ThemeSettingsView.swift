import LumiUI
import ProviderTheme
import SwiftUI

@MainActor
final class ThemeSwitcherViewModel: ObservableObject {
    private let provider: any ThemeProviding
    @Published private(set) var themes: [ProviderTheme.LumiTheme]
    @Published private(set) var selectedThemeID: String?

    init(provider: any ThemeProviding) {
        self.provider = provider
        self.themes = provider.themes
        self.selectedThemeID = provider.selectedThemeId
    }

    func selectTheme(_ id: String) {
        do {
            try provider.selectTheme(id: id)
        } catch {
            return
        }
        themes = provider.themes
        selectedThemeID = provider.selectedThemeId
    }
}

struct ThemeSettingsView: View {
    @StateObject private var viewModel: ThemeSwitcherViewModel

    init(provider: any ThemeProviding) {
        _viewModel = StateObject(wrappedValue: ThemeSwitcherViewModel(provider: provider))
    }

    var body: some View {
        AppSettingsContentScaffold(maxContentWidth: nil) {
            AppSettingSection(title: "Themes") {
                ForEach(viewModel.themes) { theme in
                    AppListRow(isSelected: viewModel.selectedThemeID == theme.id, action: {
                        viewModel.selectTheme(theme.id)
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: theme.iconName)
                                .foregroundStyle(theme.resolvedIconColor)
                                .frame(width: 20)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(theme.displayName)
                                Text(theme.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if viewModel.selectedThemeID == theme.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(theme.resolvedIconColor)
                            }
                        }
                    }
                }
            }
        }
    }
}
