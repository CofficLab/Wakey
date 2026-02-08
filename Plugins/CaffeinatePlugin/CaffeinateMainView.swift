import SwiftUI
import MagicKit

/// Wakey 应用程序的主界面
struct CaffeinateMainView: View {
    @Environment(\.demoMode) private var isDemoMode

    @State private var manager = CaffeinateManager.shared
    @State private var selectedDuration: TimeInterval = 0
    
    // 快速操作类型
    enum QuickActionType: Equatable {
        case systemAndDisplay // 防止休眠并保持屏幕常亮
        case systemOnly // 防止休眠但允许屏幕关闭
        case turnOffDisplay // 防止休眠并立即关闭屏幕
    }
    
    @State private var activeAction: QuickActionType? = nil
    
    private let quickDurations: [(title: String, value: TimeInterval)] = [
        ("永久", 0),
        ("10分钟", 600),
        ("1小时", 3600),
        ("2小时", 7200),
        ("5小时", 18000),
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header / Status
            statusHeader
            
            Divider()
            
            // Duration Selection
            durationSection
            
            // Actions
            actionsSection
            
            Spacer()
        }
        .padding(30)
        .frame(minWidth: 200)
        .onChange(of: manager.isActive) { _, newValue in
            if !newValue {
                activeAction = nil
            }
        }
    }
    
    private var statusHeader: some View {
        VStack(spacing: 16) {
            LogoView(
                variant: .general,
                isActive: isDemoMode ? true : manager.isActive
            )
            .frame(width: 80, height: 80)

            Text(isDemoMode ? "Wakey 已激活" : (manager.isActive ? "Wakey 已激活" : "Wakey 休息中"))
                .font(.largeTitle)
                .fontWeight(.bold)

            if isDemoMode || manager.isActive {
                if isDemoMode || selectedDuration > 0 {
                    Text("防止休眠：\(isDemoMode ? "2小时" : formatDuration(selectedDuration))")
                        .foregroundColor(.secondary)
                } else {
                    Text("永久防止休眠")
                        .foregroundColor(.secondary)
                }
            } else {
                Text("允许系统休眠")
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("持续时间")
                .font(.headline)
            
            HStack(spacing: 10) {
                ForEach(quickDurations, id: \.value) { option in
                    DurationButton(
                        title: option.title,
                        isSelected: selectedDuration == option.value,
                        action: {
                            selectedDuration = option.value
                            if manager.isActive, let action = activeAction {
                                activateAction(action)
                            }
                        }
                    )
                }
            }
        }
    }
    
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("模式")
                .font(.headline)
            
            VStack(spacing: 12) {
                MainActionButton(
                    title: "防止休眠且屏幕常亮",
                    subtitle: "防止系统休眠并保持显示器激活状态",
                    icon: "sun.max.fill",
                    color: .orange,
                    isSelected: isDemoMode ? true : activeAction == .systemAndDisplay,
                    action: { if !isDemoMode { toggleAction(.systemAndDisplay) } }
                )
                
                MainActionButton(
                    title: "仅防止系统休眠",
                    subtitle: "防止系统休眠，但允许显示器变暗",
                    icon: "moon.fill",
                    color: .blue,
                    isSelected: false,
                    action: { if !isDemoMode { toggleAction(.systemOnly) } }
                )
                
                MainActionButton(
                    title: "防止休眠且立刻关闭屏幕",
                    subtitle: "防止系统休眠并立即关闭显示器",
                    icon: "power",
                    color: .purple,
                    isSelected: false, // Instant action
                    action: {
                        manager.activateAndTurnOffDisplay(duration: selectedDuration)
                        activeAction = .systemOnly
                    }
                )
            }
        }
    }
    
    // MARK: - Helpers
    
    private func toggleAction(_ action: QuickActionType) {
        if activeAction == action {
            activeAction = nil
            manager.deactivate()
        } else {
            activeAction = action
            activateAction(action)
        }
    }
    
    private func activateAction(_ action: QuickActionType) {
        switch action {
        case .systemAndDisplay:
            manager.activate(mode: .systemAndDisplay, duration: selectedDuration)
        case .systemOnly:
            manager.activate(mode: .systemOnly, duration: selectedDuration)
        case .turnOffDisplay:
            manager.activateAndTurnOffDisplay(duration: selectedDuration)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        if hours > 0 {
            return "\(hours)小时 \(minutes > 0 ? "\(minutes)分钟" : "")"
        }
        return "\(minutes)分钟"
    }
}

struct DurationButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.accentColor : Color.secondary.opacity(0.1))
                )
        }
        .buttonStyle(.plain)
    }
}

struct MainActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSelected ? .white : color.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? color : color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color : (isHovering ? Color.secondary.opacity(0.05) : Color.clear))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary.opacity(0.1), lineWidth: isSelected ? 0 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

#Preview {
    CaffeinateMainView()
        .frame(height: 600)
}
