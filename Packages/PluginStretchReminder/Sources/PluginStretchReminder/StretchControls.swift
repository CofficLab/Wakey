import LumiUI
import SwiftUI

struct StretchReminderControls: View {
    @State private var manager = StretchReminderManager.shared

    // 显式声明翻译key以防止Xcode构建时删除
    private static let startButtonTitle = String(localized: "Start_Button", table: "StretchReminder")
    private static let stopButtonTitle = String(localized: "Stop_Button", table: "StretchReminder")

    var body: some View {
        HStack(spacing: 8) {
            AppButton(
                manager.isActive ? Self.stopButtonTitle : Self.startButtonTitle,
                systemImage: manager.isActive ? "stop.fill" : "play.fill",
                style: manager.isActive ? .destructive : .primary,
                size: .small
            ) {
                if manager.isActive { manager.stop() } else { manager.start() }
            }
        }
    }
}
