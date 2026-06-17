import AppKit
import SwiftUI

/// Overlay window for eye care reminder desktop gradient
class EyeCareReminderOverlayWindow: NSWindow {
    private let fadeOutDuration: TimeInterval = 2.0
    private let displayDuration: TimeInterval = 3.0

    init() {
        super.init(
            contentRect: NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        setupWindow()
    }

    private func setupWindow() {
        isOpaque = false
        backgroundColor = .clear
        level = .floating
        isReleasedWhenClosed = false
        ignoresMouseEvents = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Create gradient view
        let gradientView = EyeCareGradientView()
        contentView = NSHostingView(rootView: gradientView)
    }

    func showAndFadeOut() {
        alphaValue = 0
        orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.5
            animator().alphaValue = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) { [weak self] in
            guard let self = self else { return }

            NSAnimationContext.runAnimationGroup { context in
                context.duration = self.fadeOutDuration
                context.completionHandler = {
                    self.close()
                }
                self.animator().alphaValue = 0
            }
        }
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

                Text(String(localized: "Eye Care", table: "EyeCareReminder"))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)

                Text(String(localized: "Look away from the screen for 20 seconds to rest your eyes.", table: "EyeCareReminder"))
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

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
}
