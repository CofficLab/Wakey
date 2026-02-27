import MagicKit
import SwiftUI

/// 状态栏弹窗视图
struct StatusBar: View {
    // MARK: - Properties

    @EnvironmentObject var pluginProvider: PluginProvider

    // MARK: - Body

    private var pluginPopupViews: [AnyView] {
        pluginProvider.getStatusBarPopupViews()
    }

    var body: some View {
        VStack(spacing: 0) {
            // 第一部分：应用基本信息
            appInfoSection

            Divider()

            // 第二部分：插件提供的视图（如果有）
            if !pluginPopupViews.isEmpty {
                pluginViewsSection

                Divider()
            }

            // 第三部分：菜单项
            menuItemsSection
        }
        .frame(width: 300)
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - App Info Section

    private var appInfoSection: some View {
        VStack(spacing: 12) {
            // 应用图标和名称
            HStack(spacing: 12) {
                // 应用图标
                if let appIcon = NSApp.applicationIconImage {
                    Image(nsImage: appIcon)
                        .resizable()
                        .frame(width: 40, height: 40)
                }

                // 应用信息
                VStack(alignment: .leading, spacing: 2) {
                    Text("Wakey", tableName: "Core")
                        .font(.system(size: 15, weight: .semibold))

                    Text("v\(appVersion)", tableName: "Core")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
        .padding(12)
    }

    // MARK: - Plugin Views Section

    private var pluginViewsSection: some View {
        VStack(spacing: 0) {
            // 将视图数组缓存到局部变量，避免多次访问计算属性
            let views = pluginPopupViews
            ForEach(views.indices, id: \.self) { index in
                views[index]
                    .frame(maxWidth: .infinity)
                    .fixedSize(horizontal: false, vertical: true)

                if index < views.count - 1 {
                    Divider()
                        .padding(.horizontal, 0)
                }
            }
        }
        .padding(.vertical, 0)
    }

    // MARK: - Menu Items Section

    private var menuItemsSection: some View {
        VStack(spacing: 0) {
            // 设置
            SettingsMenuItemRow(
                title: String(localized: "Settings...", table: "Core", comment: "Menu item to open settings")
            )

            Divider()

            // 退出应用
            MenuItemRow(
                title: String(localized: "Quit", table: "Core", comment: "Menu item to quit the application"),
                color: .red,
                action: {
                    NSApp.terminate(nil)
                }
            )
        }
    }

    // MARK: - Helpers

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
}

/// 设置菜单项行
struct SettingsMenuItemRow: View {
    /// 标题
    let title: String

    /// 是否处于悬停状态
    @State private var isHovering = false

    var body: some View {
        if #available(macOS 14.0, *) {
            SettingsLink {
                HStack(spacing: 12) {
                    Text(title)
                        .font(.system(size: 13))
                        .foregroundColor(isHovering ? .white : .primary)
                        .padding(.horizontal)

                    Spacer()
                }
                .padding(.vertical, 10)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(
                Rectangle()
                    .fill(isHovering ? Color(nsColor: .selectedContentBackgroundColor) : Color.clear)
            )
            .onHover { hovering in
                isHovering = hovering
            }
        } else {
            MenuItemRow(
                title: title,
                action: {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    // 激活应用并置顶窗口
                    NSApp.activate(ignoringOtherApps: true)
                }
            )
        }
    }
}

/// 菜单项行
struct MenuItemRow: View {
    /// 标题
    let title: String
    /// 颜色
    var color: Color = .primary
    /// 点击动作
    let action: () -> Void

    /// 是否处于悬停状态
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(isHovering ? .white : color)
                    .padding(.horizontal)

                Spacer()
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            Rectangle()
                .fill(isHovering ? Color(nsColor: .selectedContentBackgroundColor) : Color.clear)
        )
        .onHover { hovering in
            isHovering = hovering
        }
    }
}

// MARK: - Preview

#Preview("StatusBar") {
    StatusBar()
        .inRootView()
        .frame(width: StatusBarController.defaultPopoverWidth)
}

#Preview("App") {
    ContentLayout()
        .inRootView()
        .frame(width: StatusBarController.defaultPopoverWidth)
}
