#if !os(macOS)
import KernelCore
import ProviderSettingView
import PluginEyeCareReminder
import PluginHydrationReminder
import PluginStretchReminder
import SwiftUI
import UIKit
import UserNotifications

/// iOS / iPadOS 主界面：底部标签页承载三个提醒功能与设置。
///
/// 与 macOS 的「状态栏弹窗 + 主窗口」不同，iOS 没有菜单栏常驻入口，
/// 因此把每个提醒插件的状态栏弹窗视图升级为整页内容：提醒逻辑完全复用
/// 插件共享实现（`*ReminderManager.shared`），宿主只负责布局。
@MainActor
struct WakeyMobileRootView: View {
    let kernel: KernelCoreContainer

    /// 记住上次停留的标签页：iOS 上与兄弟 App 一致，重开回到原标签。
    @AppStorage("WakeyMobileSelectedTab") private var selectedTab: WakeyMobileTab = .eyeCare

    var body: some View {
        TabView(selection: $selectedTab) {
            mobileTab(tab: .eyeCare) {
                AnyView(EyeCareReminderPopupView())
            }
            mobileTab(tab: .stretch) {
                AnyView(StretchReminderPopupView())
            }
            mobileTab(tab: .hydration) {
                AnyView(HydrationReminderPopupView())
            }
            WakeyMobileSettingsView(kernel: kernel)
                .tabItem { Label(WakeyMobileTab.settings.title, systemImage: WakeyMobileTab.settings.systemImage) }
                .tag(WakeyMobileTab.settings)
        }
    }

    private func mobileTab(
        tab: WakeyMobileTab,
        @ViewBuilder content: () -> AnyView
    ) -> some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    content()
                    NotificationPermissionBanner()
                }
                .padding(.horizontal)
                // iPad 上不限宽的话弹窗卡片会被拉成通栏，观感与 macOS 弹窗差异过大。
                .frame(maxWidth: 720)
            }
            .navigationTitle(tab.title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .tabItem { Label(tab.title, systemImage: tab.systemImage) }
        .tag(tab)
    }
}

/// 通知权限被拒后的提示。
///
/// 本地通知是 iOS 上 App 退到后台后唯一的提醒通道；用户在系统弹窗点了
/// 「不允许」时不会有任何回显，没有这条提示就等于背景提醒静默失效。
private struct NotificationPermissionBanner: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined

    var body: some View {
        VStack(spacing: 8) {
            if authorizationStatus == .denied {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "bell.slash.fill")
                        .foregroundStyle(.orange)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Notifications are off")
                            .font(.footnote.weight(.semibold))
                        Text("Wakey can only remind you while it is open. Turn on notifications to get reminders in the background.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 8)

                    Button("Open Settings") { openSystemSettings() }
                        .font(.footnote.weight(.semibold))
                        .buttonStyle(.borderless)
                }
                .padding(10)
                .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .task { await refreshAuthorization() }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { await refreshAuthorization() }
        }
    }

    private func refreshAuthorization() async {
        authorizationStatus = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}

enum WakeyMobileTab: String {
    case eyeCare
    case stretch
    case hydration
    case settings

    var title: LocalizedStringKey {
        switch self {
        case .eyeCare: "Eye Care"
        case .stretch: "Stretch"
        case .hydration: "Hydration"
        case .settings: "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .eyeCare: "eye.fill"
        case .stretch: "figure.walk"
        case .hydration: "drop.fill"
        case .settings: "gearshape"
        }
    }
}

/// iOS 设置页：直接消费 `SettingViewProviding` 的入口列表。
///
/// 插件（提醒、插件管理、通用、关于）在内核启动时把入口注入共享 Provider，
/// 这里按 `order` 排序列出并推入各自详情视图——与 macOS 设置窗口共用同一批
/// 入口与详情实现。
@MainActor
struct WakeyMobileSettingsView: View {
    let kernel: KernelCoreContainer
    @StateObject private var observer: SettingsEntriesObserver

    init(kernel: KernelCoreContainer) {
        self.kernel = kernel
        _observer = StateObject(
            wrappedValue: SettingsEntriesObserver(
                provider: kernel.resolveProvider((any SettingViewProviding).self)
            )
        )
    }

    var body: some View {
        NavigationStack {
            List(entries) { entry in
                NavigationLink {
                    entry.makeDetailView()
                        .navigationTitle(entry.title)
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    Label(entry.title, systemImage: entry.systemImage)
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var entries: [SettingEntryItem] {
        (observer.provider?.entries ?? []).sorted { $0.order < $1.order }
    }
}

@MainActor
private final class SettingsEntriesObserver: ObservableObject {
    let provider: (any SettingViewProviding)?
    private var handle: (any SettingViewObserverHandle)?

    init(provider: (any SettingViewProviding)?) {
        self.provider = provider
        handle = provider?.addSettingViewObserver { [weak self] event in
            guard case .entriesChanged = event else { return }
            self?.objectWillChange.send()
        }
    }
}
#endif
