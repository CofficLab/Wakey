import SwiftUI

/// Break type selector component
struct BreakTypeSelector: View {
    @State private var manager = BreakReminderManager.shared

    var body: some View {
        VStack(spacing: 0) {
            ForEach(BreakReminderManager.BreakType.allCases) { type in
                BreakTypeButton(
                    type: type,
                    isSelected: manager.currentType == type && manager.isActive,
                    action: {
                        selectType(type)
                    }
                )

                if type != BreakReminderManager.BreakType.allCases.last {
                    Divider()
                        .padding(.leading, 36)
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helper Methods

    private func selectType(_ type: BreakReminderManager.BreakType) {
        if manager.isActive {
            manager.updateType(type)
        } else {
            manager.start(type: type)
        }
    }
}

// MARK: - Break Type Button

private struct BreakTypeButton: View {
    let type: BreakReminderManager.BreakType
    let isSelected: Bool
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: type.icon)
                    .font(.system(size: 11))
                    .foregroundColor(isHovering ? .white : type.color)
                    .frame(width: 18)

                // Text column
                VStack(alignment: .leading, spacing: 2) {
                    Text(LocalizedStringKey(type.displayName), tableName: "BreakReminder")
                        .font(.system(size: 11))
                        .foregroundColor(isHovering ? .white : .primary)

                    Text(LocalizedStringKey(type.description), tableName: "BreakReminder")
                        .font(.system(size: 9))
                        .foregroundColor(isHovering ? .white.opacity(0.8) : .secondary)
                }

                Spacer()

                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(isHovering ? .white : type.color)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            Rectangle()
                .fill(isHovering ? Color(nsColor: .selectedContentBackgroundColor) : Color.clear)
        )
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

#Preview {
    BreakTypeSelector()
        .frame(width: 250)
        .padding()
}

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
