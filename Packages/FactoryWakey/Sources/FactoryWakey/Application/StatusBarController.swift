import AppKit
import KernelCore
import MenuBarHostKit
import OSLog
import SwiftUI

@MainActor
class StatusBarController: NSObject {
    nonisolated static let logger = Logger(subsystem: "com.coffic.wakey.statusbar", category: "StatusBar")

    static let defaultPopoverWidth: CGFloat = 300

    weak var kernel: KernelCoreContainer?

    private let menuBarHost = MenuBarHost()
    private var activeSources: Set<String> = []
    private var iconViewModel = StatusBarIconViewModel()

    func setupStatusBar() {
        guard !menuBarHost.isInstalled else { return }

        menuBarHost.install(
            statusView: AnyView(StatusBarIconView(viewModel: iconViewModel, kernel: kernel)),
            configuration: MenuBarHostConfiguration(
                statusViewHeight: 20,
                popoverSizing: .fixedWidth(Self.defaultPopoverWidth, maximumHeight: 800),
                accessibilityIdentifier: "wakey.statusbar.button",
                accessibilityLabel: "Wakey",
                activatesApplication: true
            )
        ) { [weak self] in
            self?.createPopupView() ?? AnyView(Text("Kernel not initialized").padding())
        }

        guard menuBarHost.isInstalled else { return }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStatusBarAppearanceUpdate(_:)),
            name: .requestStatusBarAppearanceUpdate,
            object: nil
        )
        Self.logger.info("📊 状态栏已设置")
    }

    func cleanup() {
        menuBarHost.cleanup()
        NotificationCenter.default.removeObserver(self)
    }

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

    private func createPopupView() -> AnyView {
        guard let kernel else {
            return AnyView(Text("Kernel not initialized").padding())
        }
        return FactoryWakey.makeStatusBarView(kernel: kernel)
    }

    private func updateStatusBarIconAppearance() {
        iconViewModel.isActive = !activeSources.isEmpty
        iconViewModel.activeSources = activeSources
    }
}
