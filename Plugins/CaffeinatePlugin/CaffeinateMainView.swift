import SwiftUI
import MagicKit

/// The main interface for the Wakey application
struct CaffeinateMainView: View {
    @State private var manager = CaffeinateManager.shared
    @State private var selectedDuration: TimeInterval = 0
    
    // Quick action types
    enum QuickActionType: Equatable {
        case systemAndDisplay // Prevent sleep & keep display on
        case systemOnly // Prevent sleep & allow display off
        case turnOffDisplay // Prevent sleep & turn off display immediately
    }
    
    @State private var activeAction: QuickActionType? = nil
    
    private let quickDurations: [(title: String, value: TimeInterval)] = [
        ("Indefinitely", 0),
        ("10 Min", 600),
        ("1 Hour", 3600),
        ("2 Hours", 7200),
        ("5 Hours", 18000),
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
        .frame(minWidth: 400, minHeight: 500)
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
                isActive: manager.isActive
            )
            .frame(width: 80, height: 80)
            
            Text(manager.isActive ? "Wakey is Active" : "Wakey is Resting")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if manager.isActive {
                if selectedDuration > 0 {
                    Text("Preventing sleep for \(formatDuration(selectedDuration))")
                        .foregroundColor(.secondary)
                } else {
                    Text("Preventing sleep indefinitely")
                        .foregroundColor(.secondary)
                }
            } else {
                Text("System sleep is allowed")
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Duration")
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
            Text("Mode")
                .font(.headline)
            
            VStack(spacing: 12) {
                MainActionButton(
                    title: "Keep Awake & Screen On",
                    subtitle: "Prevents system sleep and keeps display active",
                    icon: "sun.max.fill",
                    color: .orange,
                    isSelected: activeAction == .systemAndDisplay,
                    action: { toggleAction(.systemAndDisplay) }
                )
                
                MainActionButton(
                    title: "Keep Awake Only",
                    subtitle: "Prevents system sleep but allows display to dim",
                    icon: "moon.fill",
                    color: .blue,
                    isSelected: activeAction == .systemOnly,
                    action: { toggleAction(.systemOnly) }
                )
                
                MainActionButton(
                    title: "Keep Awake & Screen Off",
                    subtitle: "Prevents system sleep and turns off display now",
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
            return "\(hours)h \(minutes > 0 ? "\(minutes)m" : "")"
        }
        return "\(minutes)m"
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
}
