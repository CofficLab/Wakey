import AppKit
import SwiftUI

class StretchReminderOverlayWindow: NSWindow {
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
        let gradientView = StretchGradientView()
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
                context.completionHandler = { self.close() }
                self.animator().alphaValue = 0
            }
        }
    }
}

private struct StretchGradientView: View {
    @State private var isAnimating = false
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.orange.opacity(0.3), Color.orange.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "figure.stand")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                Text(String(localized: "Stretch", table: "StretchReminder"))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                Text(String(localized: "Time to stand up and stretch your body.", table: "StretchReminder"))
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(40)
        }
        .onAppear { isAnimating = true }
    }
}
