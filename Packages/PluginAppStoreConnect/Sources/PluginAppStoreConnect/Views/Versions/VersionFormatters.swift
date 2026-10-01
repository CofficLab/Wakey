import Foundation

/// App Store Connect 版本格式化工具
enum VersionFormatters {
    /// 格式化平台名称
    static func formatPlatform(_ platform: String) -> String {
        switch platform {
        case "MAC_OS": return "macOS"
        case "IOS": return "iOS"
        case "TV_OS": return "tvOS"
        case "VISION_OS": return "visionOS"
        default: return platform
        }
    }

    /// 格式化发布类型
    static func formatReleaseType(_ releaseType: String) -> String {
        switch releaseType {
        case "MANUAL": return "手动发布"
        case "AUTO": return "自动发布"
        case "AFTER_APPROVAL": return "审核后自动发布"
        default: return releaseType
        }
    }

    /// 格式化日期
    static func formatDate(_ dateString: String) -> String {
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium
        outputFormatter.timeStyle = .none

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
    
    /// 格式化版本状态
    static func formatAppState(_ state: String) -> String {
        switch state {
        case "ACCEPTED": return "已接受"
        case "IN_REVIEW": return "审核中"
        case "PREPARED_FOR_SUBMISSION": return "准备提交"
        case "REJECTED": return "被拒绝"
        case "WAITING_FOR_REVIEW": return "等待审核"
        default: return state
        }
    }
}
