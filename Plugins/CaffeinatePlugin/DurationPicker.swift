import SwiftUI

/// 防休眠时间选择组件
struct CaffeinateDurationPicker: View {
    @Binding var selectedDuration: TimeInterval
    let activeAction: CaffeinateManager.QuickActionType?
    
    @State private var manager = CaffeinateManager.shared
    
    private let quickDurations: [(title: String, value: TimeInterval)] = [
        ("永久", 0),
        ("10分钟", 600),
        ("1小时", 3600),
        ("2小时", 7200),
        ("5小时", 18000),
    ]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(quickDurations, id: \.value) { option in
                PopupDurationButton(
                    title: option.title,
                    isSelected: selectedDuration == option.value,
                    action: {
                        selectedDuration = option.value
                        
                        // 如果防休眠正在运行，重新计时
                        if manager.isActive, let action = activeAction {
                            switch action {
                            case .systemAndDisplay:
                                manager.activate(mode: .systemAndDisplay, duration: selectedDuration)
                            case .systemOnly:
                                manager.activate(mode: .systemOnly, duration: selectedDuration)
                            case .turnOffDisplay:
                                manager.activateAndTurnOffDisplay(duration: selectedDuration)
                            }
                        }
                    }
                )
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 时间选择按钮

private struct PopupDurationButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
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
    @State var duration: TimeInterval = 0
    return CaffeinateDurationPicker(selectedDuration: $duration, activeAction: .systemAndDisplay)
        .padding()
}
