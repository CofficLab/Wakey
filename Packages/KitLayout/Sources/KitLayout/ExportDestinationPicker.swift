import AppKit
import Foundation
import UniformTypeIdentifiers

/// 导出目录选择。
///
/// 沙盒应用不能静默地把文件写进用户的「下载」目录：
/// - 需要 `com.apple.security.files.downloads.read-write` entitlement
///   （向 Apple 申请才能拿到），而且
/// - 用户也未必期望文件自动出现在那里——导出是个需要用户确认的动作。
///
/// 用 `NSSavePanel` 让用户自己选位置则无需任何 entitlement：
/// 用户在面板中做出选择后，系统即授予该位置临时读写权限。
///
/// 这也是 CofficLab 兄弟项目（Lumi）导出诊断日志等文件时采用的方式。
@MainActor
public enum ExportDestinationPicker {
    /// 让用户选择一个导出目录。
    ///
    /// - Parameters:
    ///   - suggestedName: 建议的目录名（用户可以直接采用或改名）。
    ///   - message: 面板提示文案。
    /// - Returns: 用户选择的目录；用户取消时返回 nil。
    public static func chooseDirectory(
        suggestedName: String,
        message: String
    ) -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Export"
        panel.message = message
        panel.directoryURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first

        guard panel.runModal() == .OK else { return nil }

        let chosen = panel.url
        guard let chosen else { return nil }

        // 若用户选中的就是建议名称对应的目录，直接用；否则在其中建子目录，
        // 避免覆盖用户已有内容。
        let target = chosen.appendingPathComponent(suggestedName, isDirectory: true)
        if FileManager.default.fileExists(atPath: target.path) {
            return target
        }
        return chosen
    }

    /// 让用户选择一个导出文件位置。
    ///
    /// - Parameters:
    ///   - suggestedName: 建议的文件名。
    ///   - message: 面板提示文案。
    ///   - contentType: 文件类型；缺省时不限制。
    /// - Returns: 用户选择的文件 URL；用户取消时返回 nil。
    public static func chooseFile(
        suggestedName: String,
        message: String,
        contentType: UTType? = nil
    ) -> URL? {
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = suggestedName
        panel.message = message
        panel.prompt = "Export"
        if let contentType {
            panel.allowedContentTypes = [contentType]
        }

        guard panel.runModal() == .OK else { return nil }
        return panel.url
    }

    /// 在 Finder 中显示指定文件或目录。
    ///
    /// - Parameter url: 要显示的位置。
    public static func revealInFinder(_ url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }
}
