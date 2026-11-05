import LumiUI
import ProviderAppUpdate
import ProviderDocsView
import ProviderAppUninstall
import SwiftUI
import UniformTypeIdentifiers

/// 通用设置详情视图 —— 设置窗口「通用」标签页：六个分组卡片。
///
/// 只依赖 `GeneralSettingsViewModel`；诊断导出、更新通道、卸载扫描等
/// 业务状态全部由 ViewModel 提供，外部操作经各 `GeneralSettings*Capability` 收敛。
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
                onboardingSection
                lumiSection
                websiteSection
                updatesSection
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

    // MARK: - 新手引导

    private var onboardingSection: some View {
        AppSettingSection(
            title: pluginLocalization.string("Onboarding"),
            titleAlignment: .leading
        ) {
            VStack(spacing: 0) {
                AppSettingRow(
                    title: pluginLocalization.string("Replay Onboarding"),
                    description: pluginLocalization.string("Replay the first-launch onboarding flow."),
                    icon: "graduationcap"
                ) {
                    AppButton(
                        pluginLocalization.string("Start"),
                        systemImage: "arrow.right",
                        style: .secondary,
                        size: .small
                    ) {
                        viewModel.replayOnboarding()
                    }
                    .disabled(!viewModel.isOnboardingAvailable)
                }

                if !viewModel.manuals.isEmpty {
                    Divider()
                        .padding(.vertical, 8)

                    AppSettingRow(
                        title: pluginLocalization.string("User Manual"),
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
                }
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

    // MARK: - 网站

    private var websiteSection: some View {
        AppSettingSection(
            title: pluginLocalization.string("Website"),
            titleAlignment: .leading
        ) {
            AppSettingRow(
                title: pluginLocalization.string("Official Website"),
                description: pluginLocalization.string("The official website of Wakey."),
                icon: "globe"
            ) {
                AppButton(
                    pluginLocalization.string("Visit"),
                    systemImage: "arrow.up.forward.square",
                    style: .secondary,
                    size: .small
                ) {
                    if let url = URL(string: "https://coffic.cn/wakey") {
                        #if canImport(AppKit)
                        NSWorkspace.shared.open(url)
                        #elseif canImport(UIKit)
                        UIApplication.shared.open(url)
                        #endif
                    }
                }
            }
        }
    }

    // MARK: - 更新

    /// `allowsAppUpdates` 的宿主（Wakey 直营）展示「检查更新」行，
    /// 点击广播 `checkForUpdates` 通知，由宿主（如 Sparkle 更新插件）消费。
    private var updatesSection: some View {
        AppSettingSection(
            title: pluginLocalization.string("Updates"),
            titleAlignment: .leading
        ) {
            VStack(spacing: 0) {
                AppSettingRow(
                    title: pluginLocalization.string("Check for Updates"),
                    description: pluginLocalization.string("Check whether a newer version of Wakey is available."),
                    icon: "arrow.down.circle"
                ) {
                    AppButton(
                        pluginLocalization.string("Check..."),
                        systemImage: "arrow.triangle.2.circlepath",
                        style: .secondary,
                        size: .small
                    ) {
                        viewModel.checkForUpdates()
                    }
                }

                if viewModel.isUpdateChannelAvailable {
                    Divider()
                        .padding(.vertical, 8)

                    AppSettingRow(
                        title: pluginLocalization.string("Update Channel"),
                        description: viewModel.selectedUpdateChannel == .preview
                            ? pluginLocalization.string(
                                "Getting the preview release published on the pre branch, which may contain unresolved issues."
                            )
                            : pluginLocalization.string(
                                "Getting the stable release published on the main branch."
                            ),
                        icon: viewModel.selectedUpdateChannel == .preview ? "flask" : "checkmark.seal"
                    ) {
                        Picker(
                            pluginLocalization.string("Update Channel"),
                            selection: $viewModel.selectedUpdateChannel
                        ) {
                            Text(pluginLocalization.string("Stable")).tag(AppUpdateChannel.stable)
                            Text(pluginLocalization.string("Preview")).tag(AppUpdateChannel.preview)
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                    }
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
                        title: target.kind.displayName,
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
