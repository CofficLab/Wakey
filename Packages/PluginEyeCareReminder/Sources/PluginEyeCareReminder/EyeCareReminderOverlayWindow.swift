import AppKit
import KitReminder
import SwiftUI

/// 护眼提醒的全屏遮罩。
///
/// 遮罩覆盖所有显示器（用外接大屏工作的用户正是最需要提醒的人），
/// 具体实现见 `ReminderOverlayController`。
@MainActor
class EyeCareReminderOverlayWindow {
    private let controller = ReminderOverlayController {
        AnyView(EyeCareGradientView())
    }

    /// 在所有屏幕上显示遮罩，动画淡入后自动淡出。
    func showAndFadeOut() {
        controller.showAndFadeOut()
    }
}

/// Gradient view for eye care reminder
private struct EyeCareGradientView: View {
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.green.opacity(0.3), Color.green.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )

                Text(String(localized: "Eye Care", table: "EyeCareReminder", bundle: .module))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)

                Text(String(localized: "Look away from the screen for 20 seconds to rest your eyes.", table: "EyeCareReminder", bundle: .module))
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(40)
        }
        .onAppear {
            isAnimating = true
        }
    }
}
