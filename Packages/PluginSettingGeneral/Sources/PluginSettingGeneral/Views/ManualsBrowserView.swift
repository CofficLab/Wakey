import LumiUI
import ProviderDocsView
import SwiftUI

/// 说明书浏览器 —— 主从式布局：左侧为提供了说明书的插件名列表，
/// 右侧为选中插件的说明书内容。
///
/// ## 设计基准
///
/// 对齐兄弟项目 Lumi 的分栏列表页（插件管理 / 工具管理）：
///
/// - 列表行统一走 LumiUI 的 `AppSidebarRow`，选中态背景与文字字重由
///   主题 token（`theme.appListRowSelectedBackground` / `theme.primary`）驱动，
///   因此**跟随当前主题**，不会因为系统强调色而看不见高亮；
/// - 列表内容用 `LazyVStack(spacing: 4)` + 内边距 8；
/// - 列表栏与详情栏之间用 `AppDivider` 分隔，不用 `Divider()`；
/// - 详情栏内容内边距 22。
struct ManualsBrowserView: View {
    let manuals: [DocsEntry]

    @State private var selectedID: String?

    @Environment(\.dismiss) private var dismiss
    @LumiTheme private var theme

    private var selectedManual: DocsEntry? {
        manuals.first { $0.id == selectedID } ?? manuals.first
    }

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            AppDivider(.vertical)
            detail
        }
        .frame(minWidth: 860, minHeight: 560)
        .background(theme.background)
        .onAppear {
            if selectedID == nil {
                selectedID = manuals.first?.id
            }
        }
    }

    // MARK: - 左侧插件列表

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "book")
                    .foregroundStyle(theme.textSecondary)
                Text(pluginLocalization.string("说明书"))
                    .font(.headline)
                    .foregroundStyle(theme.textPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            AppDivider()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(manuals) { manual in
                        sidebarRow(manual)
                    }
                }
                .padding(8)
            }
            .frame(maxHeight: .infinity)
        }
        .frame(width: 220)
        .background(theme.surface)
    }

    /// 单个说明书条目：选中态由 `AppSidebarRow` 统一渲染（主题感知的
    /// 选中背景 + 半粗标题 + 强调色图标）。
    private func sidebarRow(_ manual: DocsEntry) -> some View {
        let isSelected = manual.id == selectedManual?.id
        return AppSidebarRow(
            title: manual.name,
            systemImage: "book",
            leadingColor: isSelected ? theme.primary : theme.textSecondary,
            isSelected: isSelected,
            action: { selectedID = manual.id }
        )
    }

    // MARK: - 右侧说明书内容

    private var detail: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let manual = selectedManual {
                HStack(spacing: 10) {
                    Text(manual.name)
                        .font(.headline)
                        .foregroundStyle(theme.textPrimary)
                    Spacer()
                    AppIconButton(systemImage: "xmark") {
                        dismiss()
                    }
                }
                .padding(16)

                AppDivider()

                ScrollView {
                    manual.makeView()
                        .padding(22)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                AppEmptyState(
                    icon: "book",
                    title: pluginLocalization.string("暂时还没有说明书。")
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
