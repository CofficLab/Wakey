import AppKit
import SwiftUI

/// Overlay window for break reminder desktop gradient
class BreakReminderOverlayWindow: NSWindow {
    private let fadeOutDuration: TimeInterval = 2.0
    private let displayDuration: TimeInterval = 3.0

    init(type: BreakReminderManager.BreakType) {
        super.init(
            contentRect: NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        setupWindow(for: type)
    }

    private func setupWindow(for type: BreakReminderManager.BreakType) {
        isOpaque = false
        backgroundColor = .clear
        level = .floating
        isReleasedWhenClosed = false
        ignoresMouseEvents = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Create gradient view
        let gradientView = BreakGradientView(type: type)
        contentView = NSHostingView(rootView: gradientView)
    }

    func showAndFadeOut() {
        // Fade in
        alphaValue = 0
        orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.5
            animator().alphaValue = 1.0
        }

        // Wait, then fade out
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

/// Gradient view for break reminder
private struct BreakGradientView: View {
    let type: BreakReminderManager.BreakType

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [type.color.opacity(0.3), type.color.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Icon and message
            VStack(spacing: 20) {
                Image(systemName: type.icon)
                    .font(.system(size: 80))
                    .foregroundColor(type.color)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )

                Text(type.displayName)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)

                Text(type.reminderMessage)
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
