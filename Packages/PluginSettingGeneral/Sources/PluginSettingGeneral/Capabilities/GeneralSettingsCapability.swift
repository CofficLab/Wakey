import Foundation
import ProviderAppUpdate
import ProviderDocsView
import ProviderStorage
import ProviderUninstall

#if canImport(AppKit)
import AppKit
#endif

/// 通用设置页需要的最小外部操作集合。
///
/// 收敛 `DocsViewProviding` /
/// `AppUpdateChannelProviding` /
/// `UninstallProviding` 三个 Provider，View 与 ViewModel 都不再直接接触 Provider。
@MainActor
protocol GeneralSettingsCapability {
    /// 所有提供了说明书的文档条目。
    var manuals: [DocsEntry] { get }

    // MARK: 更新通道

    var updateChannel: AppUpdateChannel { get }
    var isUpdateChannelAvailable: Bool { get }
    func setUpdateChannel(_ channel: AppUpdateChannel)

    // MARK: 卸载

    var isUninstallAvailable: Bool { get }
    func scanUninstall() async -> UninstallScan
    func prepareForUninstall() async
    func uninstall(options: UninstallOptions) async throws -> UninstallResult

    // MARK: 存储

    var isStorageAvailable: Bool { get }
    func storageSizeInBytes() async -> Int64?
    func openStorageDirectory()

    // MARK: 外部事件

    @discardableResult
    func addDocsViewObserver(
        _ callback: @escaping (DocsViewEvent) -> Void
    ) -> (any DocsViewObserverHandle)?
}

/// 默认实现：持有各 Provider，把最小操作转发给它们。
@MainActor
final class GeneralSettingsCapabilityAdapter: GeneralSettingsCapability {
    private let docsProvider: (any DocsViewProviding)?
    private let updateProvider: (any AppUpdateChannelProviding)?
    private let storageProvider: (any StorageProviding)?
    private let uninstallProvider: (any UninstallProviding)?
    private let prepareForUninstall: (@MainActor () async -> Void)?

    init(
        docsProvider: (any DocsViewProviding)?,
        updateProvider: (any AppUpdateChannelProviding)?,
        storageProvider: (any StorageProviding)?,
        uninstallProvider: (any UninstallProviding)?,
        prepareForUninstall: (@MainActor () async -> Void)?
    ) {
        self.docsProvider = docsProvider
        self.updateProvider = updateProvider
        self.storageProvider = storageProvider
        self.uninstallProvider = uninstallProvider
        self.prepareForUninstall = prepareForUninstall
    }

    var manuals: [DocsEntry] {
        docsProvider?.manualEntries ?? []
    }

    var updateChannel: AppUpdateChannel {
        updateProvider?.channel ?? .stable
    }

    var isUpdateChannelAvailable: Bool {
        updateProvider != nil
    }

    func setUpdateChannel(_ channel: AppUpdateChannel) {
        updateProvider?.setChannel(channel)
    }

    var isUninstallAvailable: Bool {
        uninstallProvider != nil
    }

    func scanUninstall() async -> UninstallScan {
        await uninstallProvider?.scan() ?? UninstallScan()
    }

    func prepareForUninstall() async {
        await prepareForUninstall?()
    }

    func uninstall(options: UninstallOptions) async throws -> UninstallResult {
        guard let uninstallProvider else {
            throw GeneralSettingsCapabilityError.unavailable("卸载服务暂不可用。")
        }
        return try await uninstallProvider.uninstall(options: options)
    }

    var isStorageAvailable: Bool {
        storageProvider != nil
    }

    func storageSizeInBytes() async -> Int64? {
        guard let storageProvider else { return nil }
        return await storageProvider.dataRootDirectorySizeInBytes()
    }

    func openStorageDirectory() {
        guard let storageURL = storageProvider?.dataRootDirectory else { return }
        // 打开版本根目录的父目录，让用户可以看到 v4/v5/v6 的全部数据。
        let storageParentURL = storageURL.deletingLastPathComponent()

        #if canImport(AppKit)
        NSWorkspace.shared.open(storageParentURL)
        #endif
    }

    @discardableResult
    func addDocsViewObserver(
        _ callback: @escaping (DocsViewEvent) -> Void
    ) -> (any DocsViewObserverHandle)? {
        docsProvider?.addDocsViewObserver(callback)
    }
}

/// Capability 抛出的服务不可用错误。
enum GeneralSettingsCapabilityError: LocalizedError {
    case unavailable(String)

    var errorDescription: String? {
        switch self {
        case .unavailable(let message):
            return message
        }
    }
}
