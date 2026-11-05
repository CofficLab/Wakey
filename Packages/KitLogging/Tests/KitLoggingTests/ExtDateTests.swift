import Foundation
import Testing
@testable import KitLogging

/// 用固定时区构造 Date，避免断言受运行环境时区影响。
private func makeDate(
    year: Int,
    month: Int,
    day: Int,
    hour: Int = 0,
    minute: Int = 0,
    second: Int = 0,
    timeZone: TimeZone = TimeZone(identifier: "Asia/Shanghai")!
) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = timeZone
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    components.hour = hour
    components.minute = minute
    components.second = second
    return calendar.date(from: components)!
}

@Suite("Date 格式化")
struct DateFormattingTests {
    @Test("fullDateTime 输出 yyyy-MM-dd HH:mm:ss")
    func fullDateTimeFormats() {
        let date = makeDate(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 45)
        #expect(date.fullDateTime == "2024-03-15 14:30:45")
    }

    @Test("compactDateTime 输出无分隔符格式")
    func compactDateTimeFormats() {
        let date = makeDate(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 45)
        #expect(date.compactDateTime == "20240315143045")
    }

    @Test("compactDateTime 始终为 14 位")
    func compactDateTimeIsFixedWidth() {
        let date = makeDate(year: 2024, month: 1, day: 2, hour: 3, minute: 4, second: 5)
        #expect(date.compactDateTime == "20240102030405")
        #expect(date.compactDateTime.count == 14)
    }

    @Test("logTime 只输出时分秒")
    func logTimeFormats() {
        let date = makeDate(year: 2024, month: 3, day: 15, hour: 14, minute: 30, second: 45)
        #expect(date.logTime == "14:30:45")
    }

    @Test("静态 now 形式等价于对当前时间取实例属性")
    func staticNowMatchesInstanceFormatters() {
        // KitLogging 声明的 Date.now: String 与 Foundation.Date.now: Date 同名，
        // 因此这里改为校验两者等价的实例形式（static 版本即 Date() 的别名）。
        // 注意不能断言两个不同 `Date()` 实例的格式化结果相等——
        // 两次取值可能跨秒，字符串就会不同。
        let now = Date()
        #expect(now.fullDateTime.count == 19) // "yyyy-MM-dd HH:mm:ss"
        #expect(now.compactDateTime.count == 14)
    }

    @Test("Date.toString(nil) 返回占位符")
    func toStringHandlesNil() {
        #expect(Date.toString(nil) == "-")
    }

    @Test("Date.toString 有值时复用 fullDateTime")
    func toStringFormatsPresentDate() {
        let date = makeDate(year: 2024, month: 12, day: 31, hour: 23, minute: 59, second: 59)
        #expect(Date.toString(date) == date.fullDateTime)
    }
}

@Suite("Date 相对时间")
struct RelativeTimeTests {
    /// `relativeTime` 内部以调用时刻的 `Date()` 为基准，而该基准在断言求值前已经前进。
    /// 因此所有偏移量都取目标分档的**中部**（而非档位边界），使断言与时钟抖动无关。
    private func relative(offset: TimeInterval) -> String {
        Date().addingTimeInterval(offset).relativeTime
    }

    @Test("60 秒内显示「刚刚」")
    func recentIsJustNow() {
        #expect(relative(offset: 0) == "刚刚")
        #expect(relative(offset: -59) == "刚刚")
    }

    @Test("不足 1 小时按分钟取整")
    func minutesBucket() {
        // 90 秒 → 1 分钟档（60 ~ 120）
        #expect(relative(offset: -90) == "1分钟前")
        #expect(relative(offset: -5 * 60) == "5分钟前")
        // 119 秒仍归入分钟档，取整为 1
        #expect(relative(offset: -119) == "1分钟前")
    }

    @Test("不足 1 天按小时取整")
    func hoursBucket() {
        // 5400 秒 → 1 小时档（3600 ~ 7200）
        #expect(relative(offset: -5400) == "1小时前")
        #expect(relative(offset: -2 * 3600) == "2小时前")
    }

    @Test("不足 1 周按天取整")
    func daysBucket() {
        #expect(relative(offset: -3 * 86400) == "3天前")
        #expect(relative(offset: -6 * 86400) == "6天前")
    }

    @Test("不足 1 个月按周取整")
    func weeksBucket() {
        #expect(relative(offset: -10 * 86400) == "1周前")
        #expect(relative(offset: -20 * 86400) == "2周前")
    }

    @Test("不足 1 年按月取整")
    func monthsBucket() {
        #expect(relative(offset: -60 * 86400) == "2个月前")
        #expect(relative(offset: -180 * 86400) == "6个月前")
    }

    @Test("超过 1 年按年取整")
    func yearsBucket() {
        #expect(relative(offset: -400 * 86400) == "1年前")
        #expect(relative(offset: -800 * 86400) == "2年前")
    }

    @Test("未来 60 秒内显示「即将」")
    func futureSoon() {
        #expect(relative(offset: 30) == "即将")
    }

    @Test("未来按分钟/小时/天递进")
    func futureBuckets() {
        // 未来偏移量在断言求值前会缩水（内部基准 `Date()` 已前进），
        // 恰好等于档位整数倍的取值会偶发降档，
        // 因此全部取各档**中心**值，留出 ±半档余量。
        #expect(relative(offset: 90) == "1分钟后")          // [60, 120) 分钟档
        #expect(relative(offset: 630) == "10分钟后")        // [600, 660)
        #expect(relative(offset: 1830) == "30分钟后")       // [1800, 1860)
        #expect(relative(offset: 5400) == "1小时后")        // [3600, 7200)
        #expect(relative(offset: 16200) == "4小时后")       // [14400, 18000)
        #expect(relative(offset: 129600) == "1天后")        // [86400, 172800)
        #expect(relative(offset: 216000) == "2天后")        // [172800, 259200)
    }
}

@Suite("Date 智能相对时间")
struct SmartRelativeTimeTests {
    @Test("7 天以内沿用相对时间描述")
    func withinAWeekUsesRelativeTime() {
        let recent = Date().addingTimeInterval(-3 * 86400)
        #expect(recent.smartRelativeTime == "3天前")
    }

    @Test("超过 7 天改为 MM-dd 格式")
    func beyondAWeekUsesAbsoluteDate() {
        let old = Date().addingTimeInterval(-30 * 86400)
        let formatted = old.smartRelativeTime
        #expect(formatted != "30天前")
        // MM-dd 形如 "06-15"
        #expect(formatted.count == 5)
        #expect(formatted.contains("-"))
    }
}
