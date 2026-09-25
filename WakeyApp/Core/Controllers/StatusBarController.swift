import AppKit
import FactoryWakey
import KernelCore
import OSLog
import SwiftUI

/// 状态栏控制器，负责状态栏图标和弹窗的管理。
@MainActor
class StatusBarController: NSObject, NSPopoverDelegate {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.statusbar", category: "StatusBar")

    static let defaultPopoverWidth: CGFloat = 300

    /// 内核容器（由 MacAgent 注入）
    weak var kernel: KernelCoreContainer?

    private var statusItem: NSStatusItem?
    private var activeSources: Set<String> = []
    private var iconViewModel = StatusBarIconViewModel()
    private var iconHostingView: InteractiveHostingView<StatusBarIconView>?
    private var popover: NSPopover?

    // MARK: - Public Methods

    func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem?.button else { return }

        let iconView = StatusBarIconView(viewModel: iconViewModel, kernel: kernel)
        let hostingView = InteractiveHostingView(rootView: iconView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        self.iconHostingView = hostingView

        button.image = nil
        button.subviews.forEach { $0.removeFromSuperview() }
        button.addSubview(hostingView)

        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: button.trailingAnchor),
            hostingView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            hostingView.heightAnchor.constraint(equalToConstant: 20),
        ])

        button.action = #selector(statusBarButtonClicked)
        button.target = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStatusBarAppearanceUpdate(_:)),
            name: .requestStatusBarAppearanceUpdate,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleApplicationResignedActive),
            name: NSApplication.didResignActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWindowChanged),
            name: NSWindow.didBecomeKeyNotification,
            object: nil
        )

        Self.logger.info("📊 状态栏已设置")
    }

    func cleanup() {
        closePopover()
        NotificationCenter.default.removeObserver(self)
        if let statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
            self.statusItem = nil
        }
    }

    // MARK: - Notification Handlers

    @objc private func handleStatusBarAppearanceUpdate(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let isActive = userInfo["isActive"] as? Bool,
              let source = userInfo["source"] as? String else { return }

        if isActive {
            activeSources.insert(source)
        } else {
            activeSources.remove(source)
        }
        updateStatusBarIconAppearance()
    }

    @objc private func handleApplicationResignedActive() {
        closePopover()
    }

    @objc private func handleWindowChanged(_ notification: Notification) {
        guard let popover, popover.isShown,
              let popoverWindow = popover.contentViewController?.view.window else { return }
        if let keyWindow = NSApp.keyWindow, keyWindow != popoverWindow {
            closePopover()
        }
    }

    // MARK: - Status Bar Actions

    @objc private func statusBarButtonClicked() {
        if let popover, popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }

    private func showPopover() {
        guard let button = statusItem?.button else { return }

        if popover == nil {
            popover = NSPopover()
            popover?.behavior = .transient
            popover?.animates = true
            popover?.delegate = self

            let popupView = createPopupView()
            let hostingController = NSHostingController(rootView: popupView)
            popover?.contentViewController = hostingController
        }

        if let contentView = popover?.contentViewController?.view {
            let fittingSize = contentView.fittingSize
            let targetHeight = min(fittingSize.height, 800)
            popover?.contentSize = NSSize(width: Self.defaultPopoverWidth, height: targetHeight)
        }

        popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

        if let popoverWindow = popover?.contentViewController?.view.window {
            popoverWindow.makeKey()
            NSApp.activate(ignoringOtherApps: true)
        }

        addGlobalEventMonitor()
    }

    private var eventMonitor: Any?

    private func addGlobalEventMonitor() {
        removeGlobalEventMonitor()
        let globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor in
                self?.closePopover()
            }
        }
        self.eventMonitor = globalMonitor
    }

    private func removeGlobalEventMonitor() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    func popoverShouldClose(_ popover: NSPopover) -> Bool { true }

    private func closePopover() {
        popover?.performClose(nil)
        removeGlobalEventMonitor()
    }

    private func createPopupView() -> AnyView {
        guard let kernel else {
            return AnyView(Text("Kernel not initialized").padding())
        }
        return FactoryWakey.makeStatusBarView(kernel: kernel)
    }

    private func updateStatusBarIconAppearance() {
        let isActive = !self.activeSources.isEmpty
        iconViewModel.isActive = isActive
        iconViewModel.activeSources = self.activeSources
    }
}
