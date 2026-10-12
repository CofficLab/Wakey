import AppKit
import LumiUI
import ProviderOnboarding
import SwiftUI

/// Onboarding 欢迎页的独立浮动窗口控制器。
///
/// 原先 onboarding 作为 popup 的 root overlay 呈现，但卡片尺寸（640×550）
/// 远大于菜单栏 popup 宽度（300pt），导致严重溢出。改为独立 NSPanel 窗口，
/// 居中显示在屏幕上，提供正常的阅读体验。
@MainActor
final class OnboardingWindowController {
    static let shared = OnboardingWindowController()

    private var panel: OnboardingPanel?
    private var hostingView: NSHostingView<AnyView>?
    private var terminateObserver: (any NSObjectProtocol)?

    private init() {
        // App 终止时自动关闭窗口，防止阻塞退出
        terminateObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.forceClose()
        }
    }

    /// 展示 onboarding 窗口。
    func show(pages: [OnboardingPageItem], finish: @escaping @MainActor () -> Void) {
        let rootView = AnyView(
            OnboardingWindowContent(pages: pages, finish: finish)
        )

        if let panel, let hostingView {
            hostingView.rootView = rootView
            panel.center()
            panel.makeKeyAndOrderFront(nil)
            panel.orderFrontRegardless()
            return
        }

        let panel = OnboardingPanel(
            contentRect: OnboardingPanel.contentRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.isMovableByWindowBackground = true
        panel.isReleasedWhenClosed = true
        panel.hidesOnDeactivate = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let hosting = NSHostingView(rootView: rootView)
        hosting.frame = panel.contentView?.bounds ?? OnboardingPanel.contentRect
        hosting.autoresizingMask = [.width, .height]
        panel.contentView = hosting

        self.panel = panel
        self.hostingView = hosting
        panel.center()
        panel.makeKeyAndOrderFront(nil)
        panel.orderFrontRegardless()
    }

    /// 关闭并释放窗口。
    func close() {
        panel?.orderOut(nil)
        panel?.close()
        panel = nil
        hostingView = nil
    }

    /// 强制关闭窗口（用于 app 终止时）。
    private func forceClose() {
        panel?.orderOut(nil)
        panel?.close()
        panel = nil
        hostingView = nil
        if let observer = terminateObserver {
            NotificationCenter.default.removeObserver(observer)
            terminateObserver = nil
        }
    }
}

/// 允许成为 key window 的无边框浮层，保证按钮可点击。
final class OnboardingPanel: NSPanel {
    static let contentRect = NSRect(x: 0, y: 0, width: 480, height: 440)

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

/// Onboarding 窗口内的 SwiftUI 内容。
///
/// 从原 `OnboardingOverlay` + `OnboardingCard` 合并而来，
/// 适配独立窗口的呈现方式：自带半透明背景遮罩 + 卡片居中。
private struct OnboardingWindowContent: View {
    let pages: [OnboardingPageItem]
    let finish: @MainActor () -> Void
    @State private var pageIndex = 0

    var body: some View {
        ZStack {
            // 窗口级背景：深色半透明遮罩 + 圆角裁剪
            Color.black.opacity(0.001) // 几乎透明，但确保窗口可接收事件

            OnboardingCard(pages: pages, index: $pageIndex, finish: finish)
        }
        .frame(
            width: OnboardingPanel.contentRect.width,
            height: OnboardingPanel.contentRect.height
        )
    }
}
