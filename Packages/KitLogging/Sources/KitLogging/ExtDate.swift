import Foundation
import SwiftUI

/// Date 类型的扩展，提供常用的日期格式化和转换功能
public extension Date {
    /// 获取当前时间的标准格式字符串
    ///
    /// 返回格式为 "yyyy-MM-dd HH:mm:ss" 的当前时间字符串，使用系统当前时区
    ///
    /// # 示例
    /// ```swift
    /// let currentTime = Date.nowString
    /// print(currentTime) // 输出类似: "2024-03-15 14:30:45"
    /// ```
    static var nowString: String {
        Date().fullDateTime
    }
    
    /// 获取当前时间的紧凑格式字符串
    ///
    /// 返回格式为 "yyyyMMddHHmmss" 的当前时间字符串，使用系统当前时区
    ///
    /// # 示例
    /// ```swift
    /// let compactTime = Date.nowCompactString
    /// print(compactTime) // 输出类似: "20240315143045"
    /// ```
    static var nowCompactString: String {
        Date().compactDateTime
    }
    
    // MARK: - 实例属性
    
    /// 完整的日期时间字符串
    ///
    /// 将日期转换为 "yyyy-MM-dd HH:mm:ss" 格式的字符串，使用系统当前时区
    ///
    /// # 示例
    /// ```swift
    /// let date = Date()
    /// print(date.fullDateTime) // 输出类似: "2024-03-15 14:30:45"
    /// ```
    var fullDateTime: String {
        DateFormatters.fullDateTime.string(from: self)
    }
    
    /// 紧凑的日期时间字符串
    ///
    /// 将日期转换为 "yyyyMMddHHmmss" 格式的字符串，使用系统当前时区
    ///
    /// # 示例
    /// ```swift
    /// let date = Date()
    /// print(date.compactDateTime) // 输出类似: "20240315143045"
    /// ```
    var compactDateTime: String {
        DateFormatters.compactDateTime.string(from: self)
    }
    
    /// 日志时间字符串
    ///
    /// 将日期转换为 "HH:mm:ss" 格式的字符串，适用于日志记录
    ///
    /// # 示例
    /// ```swift
    /// let date = Date()
    /// print(date.logTime) // 输出类似: "14:30:45"
    /// ```
    var logTime: String {
        DateFormatters.logTime.string(from: self)
    }
    
    // MARK: - 静态工具方法
    
    /// 将可选日期转换为字符串
    ///
    /// - Parameter date: 需要转换的可选日期
    /// - Returns: 如果日期存在，返回格式化的日期字符串；如果为 nil，返回 "-"
    ///
    /// # 示例
    /// ```swift
    /// let date: Date? = Date()
    /// print(Date.toString(date)) // 输出类似: "2024-03-15 14:30:45"
    ///
    /// let nilDate: Date? = nil
    /// print(Date.toString(nilDate)) // 输出: "-"
    /// ```
    static func toString(_ date: Date?) -> String {
        guard let date = date else { return "-" }
        return date.fullDateTime
    }
    
    /// 相对时间字符串
    ///
    /// 将日期转换为相对于当前时间的描述，如"刚刚"、"5分钟前"、"2小时前"、"3天前"等
    ///
    /// # 示例
    /// ```swift
    /// let fiveMinutesAgo = Date().addingTimeInterval(-300)
    /// print(fiveMinutesAgo.relativeTime) // 输出: "5分钟前"
    /// 
    /// let twoHoursAgo = Date().addingTimeInterval(-7200)
    /// print(twoHoursAgo.relativeTime) // 输出: "2小时前"
    /// ```
    var relativeTime: String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(self)
        
        // 如果是未来时间
        if timeInterval < 0 {
            let futureInterval = -timeInterval
            if futureInterval < 60 {
                return "即将"
            } else if futureInterval < 3600 {
                let minutes = Int(futureInterval / 60)
                return "\(minutes)分钟后"
            } else if futureInterval < 86400 {
                let hours = Int(futureInterval / 3600)
                return "\(hours)小时后"
            } else {
                let days = Int(futureInterval / 86400)
                return "\(days)天后"
            }
        }
        
        // 过去时间
        if timeInterval < 60 {
            return "刚刚"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)分钟前"
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return "\(hours)小时前"
        } else if timeInterval < 604800 {
            let days = Int(timeInterval / 86400)
            return "\(days)天前"
        } else if timeInterval < 2592000 {
            let weeks = Int(timeInterval / 604800)
            return "\(weeks)周前"
        } else if timeInterval < 31536000 {
            let months = Int(timeInterval / 2592000)
            return "\(months)个月前"
        } else {
            let years = Int(timeInterval / 31536000)
            return "\(years)年前"
        }
    }
    
    /// 智能相对时间字符串
    ///
    /// 根据时间间隔智能选择最合适的显示格式：
    /// - 1分钟内：显示"刚刚"
    /// - 1小时内：显示分钟
    /// - 1天内：显示小时
    /// - 7天内：显示天数
    /// - 超过7天：显示具体日期
    ///
    /// # 示例
    /// ```swift
    /// let date = Date().addingTimeInterval(-86400 * 10) // 10天前
    /// print(date.smartRelativeTime) // 输出具体日期格式
    /// ```
    var smartRelativeTime: String {
        let timeInterval = Date().timeIntervalSince(self)
        
        if timeInterval < 604800 { // 7天内使用相对时间
            return relativeTime
        } else { // 超过7天显示具体日期
            return DateFormatters.shortDate.string(from: self)
        }
    }
}

/// 固定格式的日期格式化器。
///
/// 所有 formatter 都固定 `en_US_POSIX` + 公历：`yyyyMMddHHmmss` 这类字符串
/// 用于文件名与日志键，若跟随用户日历会变成佛历/和历年份或阿拉伯数字，
/// 解析方会直接失败。`DateFormatter` 创建开销大，这里只建一次。
enum DateFormatters {
    static let fullDateTime: DateFormatter = make("yyyy-MM-dd HH:mm:ss", timeZone: .current)
    static let compactDateTime: DateFormatter = make("yyyyMMddHHmmss", timeZone: .current)
    static let logTime: DateFormatter = make("HH:mm:ss", timeZone: .current)
    static let shortDate: DateFormatter = make("MM-dd", timeZone: .current)

    private static func make(_ format: String, timeZone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = timeZone
        formatter.dateFormat = format
        return formatter
    }
}
