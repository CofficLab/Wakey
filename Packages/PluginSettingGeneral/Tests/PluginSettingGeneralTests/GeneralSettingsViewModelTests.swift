import Foundation
import ProviderAppUpdate
import ProviderDiagnostics
import ProviderDocsView
import ProviderAppUninstall
import SwiftUI
import Testing
@testable import PluginSettingGeneral

/// 完全可控的 capability 替身，避免依赖真实 Provider 与磁盘。
///
/// 同一替身同时实现六个细分能力，便于按 Lumi 的能力拆分结构注入。
@MainActor
private final class StubCapability: GeneralSettingsDocsCapability,
    GeneralSettingsUpdateChannelCapability,
    GeneralSettingsOnboardingCapability,
    GeneralSettingsDiagnosticsCapability,
    GeneralSettingsStorageCapability,
    GeneralSettingsUninstallCapability
{
    var manuals: [DocsEntry]
    var updateChannel: AppUpdateChannel
    var isUpdateChannelAvailable: Bool
    var isOnboardingAvailable: Bool
    var isDiagnosticsAvailable: Bool
    var isUninstallAvailable: Bool
    var isStorageAvailable: Bool
    var storageSize: Int64?
    var storageSizeCalls = 0
    var openStorageDirectoryCalls = 0
    var scanCalls = 0
    var prepareCalls = 0
    var lastUninstallOptions: UninstallOptions?
    var setUpdateChannelCalls: [AppUpdateChannel] = []
    var uninstallError: Error?
    var replayOnboardingCalls = 0
    var makeDiagnosticsArchiveCalls = 0
    var diagnosticsError: Error?

    init(
        manuals: [DocsEntry] = [],
        updateChannel: AppUpdateChannel = .stable,
        isUpdateChannelAvailable: Bool = true,
        isOnboardingAvailable: Bool = true,
        isDiagnosticsAvailable: Bool = true,
        isUninstallAvailable: Bool = true,
        isStorageAvailable: Bool = true,
        storageSize: Int64? = nil
    ) {
        self.manuals = manuals
        self.updateChannel = updateChannel
        self.isUpdateChannelAvailable = isUpdateChannelAvailable
        self.isOnboardingAvailable = isOnboardingAvailable
        self.isDiagnosticsAvailable = isDiagnosticsAvailable
        self.isUninstallAvailable = isUninstallAvailable
        self.isStorageAvailable = isStorageAvailable
        self.storageSize = storageSize
    }

    func setUpdateChannel(_ channel: AppUpdateChannel) {
        setUpdateChannelCalls.append(channel)
        updateChannel = channel
    }

    func replayOnboarding() {
        replayOnboardingCalls += 1
    }

    func makeDiagnosticsArchive() async throws -> DiagnosticsArchive {
        makeDiagnosticsArchiveCalls += 1
        if let diagnosticsError { throw diagnosticsError }
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("wakey-diagnostics-\(UUID().uuidString).zip")
        return DiagnosticsArchive(url: url, filename: url.lastPathComponent)
    }

    func scanUninstall() async -> UninstallScan {
        scanCalls += 1
        return UninstallScan()
    }

    func prepareForUninstall() async {
        prepareCalls += 1
    }

    func uninstall(options: UninstallOptions) async throws -> UninstallResult {
        lastUninstallOptions = options
        if let uninstallError { throw uninstallError }
        return UninstallResult(
            removedTargetIDs: ["probe"],
            failures: [],
            applicationMovedToTrash: false
        )
    }

    func storageSizeInBytes() async -> Int64? {
        storageSizeCalls += 1
        return storageSize
    }

    func openStorageDirectory() {
        openStorageDirectoryCalls += 1
    }

    @discardableResult
    func addDocsViewObserver(_ callback: @escaping (DocsViewEvent) -> Void) -> (any DocsViewObserverHandle)? {
        nil
    }
}

/// 用同一个替身填充六个能力入口，保持 ViewModel 构造调用简洁。
@MainActor
private func makeViewModel(_ capability: StubCapability) -> GeneralSettingsViewModel {
    GeneralSettingsViewModel(
        docsCapability: capability,
        updateChannelCapability: capability,
        onboardingCapability: capability,
        diagnosticsCapability: capability,
        storageCapability: capability,
        uninstallCapability: capability
    )
}

@Suite("GeneralSettingsViewModel 初始化")
@MainActor
struct GeneralSettingsViewModelInitTests {
    @Test("从 capability 同步说明书与更新通道")
    func syncsInitialState() {
        let capability = StubCapability(updateChannel: .preview)
        let model = makeViewModel(capability)

        #expect(model.selectedUpdateChannel == .preview)
        #expect(model.manuals.isEmpty)
    }

    @Test("变更更新通道会透传到 capability")
    func updateChannelWritesThrough() {
        let capability = StubCapability()
        let model = makeViewModel(capability)

        model.selectedUpdateChannel = .preview
        #expect(capability.setUpdateChannelCalls == [.preview])
    }

    @Test("重复设置同一通道不重复透传")
    func sameChannelIsNotReposted() {
        let capability = StubCapability()
        let model = makeViewModel(capability)

        model.selectedUpdateChannel = .stable
        #expect(capability.setUpdateChannelCalls.isEmpty)
    }

    @Test("可用性透传 capability")
    func exposesAvailabilityFlags() {
        let capability = StubCapability(
            isUpdateChannelAvailable: false,
            isUninstallAvailable: false,
            isStorageAvailable: false
        )
        let model = makeViewModel(capability)

        #expect(!model.isUpdateChannelAvailable)
        #expect(!model.isUninstallAvailable)
        #expect(!model.isStorageAvailable)
    }
}

@Suite("GeneralSettingsViewModel 存储")
@MainActor
struct GeneralSettingsViewModelStorageTests {
    @Test("存储不可用时给出不可用提示")
    func storageUnavailableDescription() {
        let model = makeViewModel(StubCapability(isStorageAvailable: false))
        #expect(model.storageSizeDescription == "存储服务暂不可用")
    }

    @Test("尚未计算出容量时给出计算中提示")
    func storagePendingDescription() async {
        let model = makeViewModel(StubCapability(storageSize: nil))
        #expect(model.storageSizeDescription == "正在计算…")

        // 等待 init 中的异步刷新落地
        try? await Task.sleep(for: .milliseconds(50))
        #expect(model.storageSizeInBytes == nil)
    }

    @Test("refreshStorageUsage 会重置并重新拉取容量")
    func refreshStorageUsageResets() async {
        let capability = StubCapability(storageSize: 1024)
        let model = makeViewModel(capability)

        try? await Task.sleep(for: .milliseconds(50))
        #expect(model.storageSizeInBytes == 1024)

        capability.storageSize = 2048
        model.refreshStorageUsage()
        #expect(model.storageSizeInBytes == nil)

        try? await Task.sleep(for: .milliseconds(50))
        #expect(model.storageSizeInBytes == 2048)
        #expect(capability.storageSizeCalls >= 2)
    }

    @Test("openStorageDirectory 透传给 capability")
    func opensStorageDirectory() {
        let capability = StubCapability()
        let model = makeViewModel(capability)

        model.openStorageDirectory()
        #expect(capability.openStorageDirectoryCalls == 1)
    }

    @Test("刷新说明书读取 capability 最新值")
    func refreshManualsReadsLatest() {
        let capability = StubCapability()
        let model = makeViewModel(capability)
        #expect(model.manuals.isEmpty)

        capability.manuals = [DocsEntry(id: "manual", name: "使用手册") { Text("使用手册") }]
        model.refreshManuals()
        #expect(model.manuals.count == 1)
    }
}

@Suite("GeneralSettingsViewModel 卸载流程")
@MainActor
struct GeneralSettingsViewModelUninstallTests {
    @Test("卸载服务不可用时给出警告反馈")
    func beginUninstallUnavailable() {
        let model = makeViewModel(StubCapability(isUninstallAvailable: false))

        model.beginUninstall()

        #expect(model.uninstallFeedbackKind == .warning)
        #expect(model.uninstallFeedback == "卸载服务暂不可用。")
        #expect(!model.isScanningUninstall)
    }

    @Test("beginUninstall 重置选项并进入扫描态")
    func beginUninstallResetsOptions() async {
        let capability = StubCapability()
        let model = makeViewModel(capability)
        model.removeKeychainCredentials = false
        model.removeApplication = false

        model.beginUninstall()

        #expect(model.removeKeychainCredentials)
        #expect(model.removeApplication)
        #expect(model.uninstallFeedback == nil)
        #expect(model.uninstallFeedbackKind == .info)

        try? await Task.sleep(for: .milliseconds(50))
        #expect(capability.scanCalls == 1)
        #expect(!model.isScanningUninstall)
        #expect(model.uninstallScan != nil)
    }

    @Test("performUninstall 在服务不可用时不执行")
    func performUninstallUnavailable() {
        let capability = StubCapability(isUninstallAvailable: false)
        let model = makeViewModel(capability)

        model.performUninstall()

        #expect(model.uninstallFeedbackKind == .warning)
        #expect(capability.lastUninstallOptions == nil)
    }

    @Test("UninstallFeedbackKind 映射到横幅类型")
    func feedbackKindMapping() {
        #expect(GeneralSettingsViewModel.UninstallFeedbackKind.info.bannerKind == .info)
        #expect(GeneralSettingsViewModel.UninstallFeedbackKind.success.bannerKind == .success)
        #expect(GeneralSettingsViewModel.UninstallFeedbackKind.warning.bannerKind == .warning)
        #expect(GeneralSettingsViewModel.UninstallFeedbackKind.error.bannerKind == .error)
    }
}

@Suite("GeneralSettingsViewModel 新手引导与诊断")
@MainActor
struct GeneralSettingsViewModelOnboardingDiagnosticsTests {
    @Test("新手引导可用性透传 capability")
    func exposesOnboardingAvailability() {
        let model = makeViewModel(StubCapability(isOnboardingAvailable: false))
        #expect(!model.isOnboardingAvailable)
    }

    @Test("replayOnboarding 透传给 capability")
    func replaysOnboarding() {
        let capability = StubCapability()
        let model = makeViewModel(capability)

        model.replayOnboarding()

        #expect(capability.replayOnboardingCalls == 1)
    }

    @Test("诊断可用性透传 capability")
    func exposesDiagnosticsAvailability() {
        let model = makeViewModel(StubCapability(isDiagnosticsAvailable: false))
        #expect(!model.isDiagnosticsAvailable)
    }

    @Test("诊断不可用时导出给出提示且不调用服务")
    func exportDiagnosticsUnavailable() {
        let capability = StubCapability(isDiagnosticsAvailable: false)
        let model = makeViewModel(capability)

        model.exportDiagnostics()

        #expect(model.diagnosticsFeedback == "日志服务暂不可用。")
        #expect(capability.makeDiagnosticsArchiveCalls == 0)
        #expect(!model.isExportingDiagnostics)
    }
}

@Suite("AppVersion")
struct AppVersionTests {
    @Test("在无 App bundle 的测试环境中不抛错")
    func resolvesWithoutBundle() {
        // 测试 bundle 通常没有版本号，返回 nil 属正常；
        // 关键是该属性不会崩溃。
        let version = AppVersion.current
        if let version {
            #expect(!version.isEmpty)
        }
    }
}
