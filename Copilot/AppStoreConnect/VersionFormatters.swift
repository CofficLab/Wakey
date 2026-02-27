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
}
