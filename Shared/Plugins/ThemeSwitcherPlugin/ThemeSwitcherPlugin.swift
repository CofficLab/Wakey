import SwiftUI
import WakeryUI

actor ThemeSwitcherPlugin: SuperPlugin {
    static let id = "ThemeSwitcher"
    static let displayName = "Themes"
    static let description = "Switch Wakey visual themes"
    static let iconName = "paintpalette"
    static let isConfigurable = false
    static let order = 79

    @MainActor
    func addStatusBarPopupView() -> AnyView? {
        AnyView(ThemeSwitcherView())
    }
}

private struct ThemeSwitcherView: View {
    @EnvironmentObject private var themeVM: AppThemeVM

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "paintpalette")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)

                Text("Themes")
                    .font(.system(size: 13, weight: .semibold))

                Spacer()
            }
            .padding(.horizontal, 12)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8),
                ],
                spacing: 8
            ) {
                ForEach(themeVM.themes) { theme in
                    ThemeOptionButton(
                        theme: theme,
                        isSelected: themeVM.currentThemeId == theme.id
                    ) {
                        themeVM.selectTheme(theme.id)
                    }
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 12)
    }
}

private struct ThemeOptionButton: View {
    let theme: WakeryUIThemeContribution
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(theme.iconColor)
                    Image(systemName: theme.iconName)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 18, height: 18)

                Text(theme.compactName)
                    .font(.system(size: 12, weight: isSelected ? .semibold : .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer(minLength: 0)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(theme.iconColor)
                }
            }
            .padding(.horizontal, 8)
            .frame(height: 30)
            .background(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(isSelected ? theme.iconColor.opacity(0.14) : Color.secondary.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(isSelected ? theme.iconColor.opacity(0.55) : Color.secondary.opacity(0.12), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
