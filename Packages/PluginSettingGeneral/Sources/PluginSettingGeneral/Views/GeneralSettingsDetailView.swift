import LumiUI
import ProviderDocsView
import ProviderUninstall
import SwiftUI
import UniformTypeIdentifiers

/// 通用设置详情视图 —— 设置窗口「通用」标签页：四个分组卡片。
///
/// 只依赖 `GeneralSettingsViewModel`；诊断导出、卸载扫描等业务状态全部由
/// ViewModel 提供，外部操作经各 `GeneralSettings*Capability` 收敛。
///
/// Wakey 通过 Mac App Store 分发，更新由系统与 App Store 负责，
/// 因此这里不提供「检查更新」入口。
struct GeneralSettingsDetailView: View {
    let version: String?
    @ObservedObject var viewModel: GeneralSettingsViewModel

    /// 是否展示说明书浏览器（纯 UI 状态）。
    @State private var isPresentingManuals = false
    /// 是否展示卸载确认弹窗（纯 UI 状态）。
    @State private var isPresentingUninstall = false

    /// App bundle 元数据（名称 / 包名 / 版本 / 构建）。
    private let bundleInfo = AppBundleInfo()

    var body: some View {
        AppSettingsContentScaffold(maxContentWidth: nil) {
            VStack(alignment: .leading, spacing: 24) {
                manualSection
                lumiSection
                diagnosticsSection
                uninstallSection
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .sheet(isPresented: $isPresentingManuals) {
            if !viewModel.manuals.isEmpty {
                ManualsBrowserView(manuals: viewModel.manuals)
            }
        }
        .sheet(isPresented: $isPresentingUninstall) {
            uninstallSheet
        }
    }

    // MARK: - 使用手册

    /// 「使用手册」分组：仅在有插件提供说明书时展示入口，否则整组隐藏。
    @ViewBuilder
    private var manualSection: some View {
        if !viewModel.manuals.isEmpty {
            AppSettingSection(
                title: pluginLocalization.string("User Manual"),
                titleAlignment: .leading
            ) {
                AppSettingRow(
                    title: pluginLocalization.string("Browse Manuals"),
                    description: pluginLocalization.string("Usage guides for every feature."),
                    icon: "book"
                ) {
                    AppButton(
                        pluginLocalization.string("Open"),
                        systemImage: "book.pages",
                        style: .secondary,
                        size: .small
                    ) {
                        isPresentingManuals = true
                    }
                }
                .disabled(viewModel.manuals.isEmpty)
            }
        }
    }

    // MARK: - Wakey（应用信息）

    private var lumiSection: some View {
        AppSettingSection(
            title: pluginLocalization.string("Wakey"),
            titleAlignment: .leading
        ) {
            VStack(spacing: 0) {
                AppSettingRow(
                    title: pluginLocalization.string("Name"),
                    description: bundleInfo.name,
                    icon: "app"
                ) {
                    EmptyView()
                }
                Divider()
                    .padding(.vertical, 8)
                AppSettingRow(
                    title: pluginLocalization.string("Bundle ID"),
                    description: bundleInfo.bundleIdentifier,
                    icon: "number"
                ) {
                    EmptyView()
                }
                Divider()
                    .padding(.vertical, 8)
                AppSettingRow(
                    title: pluginLocalization.string("Version"),
                    description: bundleInfo.version ?? pluginLocalization.string("Not Set"),
                    icon: "info.circle"
                ) {
                    EmptyView()
                }
                Divider()
                    .padding(.vertical, 8)
                AppSettingRow(
                    title: pluginLocalization.string("Build"),
                    description: bundleInfo.build ?? pluginLocalization.string("Not Set"),
                    icon: "hammer"
                ) {
                    EmptyView()
                }
                Divider()
                    .padding(.vertical, 8)
                AppSettingRow(
                    title: pluginLocalization.string("Storage"),
                    description: viewModel.storageSizeDescription,
                    icon: "internaldrive"
                ) {
                    AppButton(
                        pluginLocalization.string("Open Database Folder"),
                        systemImage: "folder",
                        style: .secondary,
                        size: .small
                    ) {
                        viewModel.openStorageDirectory()
                    }
                    .disabled(!viewModel.isStorageAvailable)
                }
            }
        }
    }

    // MARK: - 诊断日志

    private var diagnosticsSection: some View {
        AppSettingSection(
            title: pluginLocalization.string("Diagnostics"),
            titleAlignment: .leading
        ) {
            VStack(spacing: 0) {
                AppSettingRow(
                    title: pluginLocalization.string("Export Logs"),
                    description: pluginLocalization.string("Pack the recent runtime log for easier issue reporting."),
                    icon: "doc.badge.arrow.up"
                ) {
                    AppButton(
                        viewModel.isExportingDiagnostics
                            ? pluginLocalization.string("Exporting...")
                            : pluginLocalization.string("Export"),
                        systemImage: viewModel.isExportingDiagnostics ? "hourglass" : "square.and.arrow.up",
                        style: .secondary,
                        size: .small
                    ) {
                        viewModel.exportDiagnostics()
                    }
                    .disabled(viewModel.isExportingDiagnostics || !viewModel.isDiagnosticsAvailable)
                }

                if let diagnosticsFeedback = viewModel.diagnosticsFeedback {
                    Divider()
                        .padding(.vertical, 8)
                    Text(diagnosticsFeedback)
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    // MARK: - 卸载 Wakey

    private var uninstallSection: some View {
        AppSettingSection(
            title: pluginLocalization.string("Uninstall"),
            titleAlignment: .leading
        ) {
            AppSettingRow(
                title: pluginLocalization.string("Completely Uninstall Wakey"),
                description: pluginLocalization.string(
                    "Clears Wakey's plugin data, preferences, extension data, and optional credentials."
                ),
                icon: "trash"
            ) {
                AppButton(
                    pluginLocalization.string("Uninstall..."),
                    systemImage: "trash",
                    style: .destructive,
                    size: .small
                ) {
                    viewModel.beginUninstall()
                    isPresentingUninstall = true
                }
            }
        }
    }

    private var uninstallSheet: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(pluginLocalization.string("Completely Uninstall Wakey"))
                .font(.appTitle)

            Text(pluginLocalization.string(
                "This will permanently delete data saved by Wakey. Your own data, preferences, and files will not be deleted."
            ))
                .font(.appBody)
                .foregroundStyle(.secondary)

            if viewModel.isScanningUninstall {
                AppStatusBanner(
                    kind: .loading,
                    title: pluginLocalization.string("Scanning Wakey data...")
                )
            } else if let uninstallScan = viewModel.uninstallScan {
                uninstallSummary(scan: uninstallScan)
            }

            if let uninstallFeedback = viewModel.uninstallFeedback {
                AppStatusBanner(kind: viewModel.uninstallFeedbackKind.bannerKind, title: uninstallFeedback)
                    .textSelection(.enabled)
            }

            AppDivider()

            VStack(spacing: 0) {
                AppSettingToggleRow(
                    pluginLocalization.string("Also move the Wakey app to Trash"),
                    icon: "trash",
                    isOn: $viewModel.removeApplication
                )

                if let uninstallScan = viewModel.uninstallScan, uninstallScan.keychainTargetCount > 0 {
                    AppSettingToggleRow(
                        pluginLocalization.string("Also delete API Keys, passwords, and credentials from Keychain"),
                        icon: "key.fill",
                        isOn: $viewModel.removeKeychainCredentials
                    )
                }
            }

            HStack {
                Spacer()
                AppButton(pluginLocalization.string("Cancel"), style: .ghost, size: .small) {
                    isPresentingUninstall = false
                }
                AppButton(
                    viewModel.isUninstalling
                        ? pluginLocalization.string("Uninstalling...")
                        : (viewModel.removeApplication
                            ? pluginLocalization.string("Permanent Delete and Uninstall")
                            : pluginLocalization.string("Clear Data and Quit")),
                    systemImage: viewModel.isUninstalling ? "hourglass" : "trash.fill",
                    style: .destructive,
                    size: .small
                ) {
                    viewModel.performUninstall()
                }
                .disabled(
                    viewModel.isScanningUninstall
                    || viewModel.isUninstalling
                    || !viewModel.isUninstallAvailable
                )
            }
        }
        .padding(24)
        .frame(width: 520)
    }

    @ViewBuilder
    private func uninstallSummary(scan: UninstallScan) -> some View {
        AppSettingSection(
            title: pluginLocalization.string(
                "Will process %lld items of Wakey data, %@ in total.",
                scan.targets.count,
                formattedBytes(scan.totalSizeInBytes)
            ),
            titleAlignment: .leading
        ) {
            VStack(spacing: 0) {
                ForEach(Array(scan.targets.prefix(8).enumerated()), id: \.element.id) { index, target in
                    AppSettingRow(
                        title: target.kind.displayName(branding: .wakey),
                        description: target.sizeInBytes > 0 ? formattedBytes(target.sizeInBytes) : "—",
                        icon: uninstallIcon(for: target)
                    ) {
                        EmptyView()
                    }

                    if index < min(scan.targets.count, 8) - 1 {
                        Divider()
                            .padding(.vertical, 8)
                    }
                }

                if scan.targets.count > 8 {
                    Text(pluginLocalization.string(
                        "%lld more items will be processed after confirmation.",
                        scan.targets.count - 8
                    ))
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                }
            }
        }
    }

    private func uninstallIcon(for target: UninstallTarget) -> String {
        target.kind == .application ? "folder" : "key.fill"
    }

    private func formattedBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
