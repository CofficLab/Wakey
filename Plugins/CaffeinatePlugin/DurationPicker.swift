import SwiftUI

/// Anti-sleep duration picker component
struct CaffeinateDurationPicker: View {
    @State private var manager = CaffeinateManager.shared
    
    private let quickDurations: [(title: LocalizedStringKey, value: TimeInterval)] = [
        ("Indefinite", 0),
        ("10_mins_Short", 600),
        ("1_hr_Short", 3600),
        ("2_hrs_Short", 7200),
        ("5_hrs_Short", 18000),
    ]
    
    /// 持续时间选择器的视图主体
    var body: some View {
        HStack(spacing: 4) {
            ForEach(quickDurations, id: \.value.self) { option in
                PopupDurationButton(
                    title: option.title,
                    isSelected: manager.selectedDuration == option.value,
                    action: {
                        manager.selectedDuration = option.value
                        
                        // 如果防休眠正在运行，则重启计时器
                        if manager.isActive, let action = manager.activeAction {
                            switch action {
                            case .systemAndDisplay:
                                manager.activate(mode: .systemAndDisplay, duration: manager.selectedDuration)
                            case .systemOnly:
                                manager.activate(mode: .systemOnly, duration: manager.selectedDuration)
                            case .turnOffDisplay:
                                manager.activateAndTurnOffDisplay(duration: manager.selectedDuration)
                            }
                        }
                    }
                )
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Duration Selection Button

/// 持续时间选择按钮
private struct PopupDurationButton: View {
    let title: LocalizedStringKey
    let isSelected: Bool
    let action: () -> Void

    /// 按钮的视图主体
    var body: some View {
        Button(action: action) {
            Text(title, tableName: "Caffeinate")
                .font(.system(size: 10))
                .foregroundColor(isSelected ? .white : .secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.1))
                .cornerRadius(3)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CaffeinateDurationPicker()
        .padding()
}

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
