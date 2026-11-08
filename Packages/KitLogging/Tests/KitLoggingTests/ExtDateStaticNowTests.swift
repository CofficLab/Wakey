import Foundation
import Testing
@testable import KitLogging

@Suite("Date 静态格式化属性")
struct DateStaticNowTests {
    @Test("Date.nowString 输出 yyyy-MM-dd HH:mm:ss")
    func staticNowStringFormats() {
        let value = Date.nowString
        #expect(value.count == 19)
        #expect(value.contains("-"))
        #expect(value.contains(":"))
    }

    @Test("Date.nowCompactString 输出 14 位紧凑格式")
    func staticNowCompactStringFormats() {
        let value = Date.nowCompactString
        #expect(value.count == 14)
        #expect(value.allSatisfy { $0.isNumber })
    }

    @Test("静态形式与实例形式使用同一套格式")
    func staticFormsMatchInstanceForms() {
        // 分别取样以避免跨秒导致字符串不同，只比较格式特征。
        #expect(Date.nowString.count == Date().fullDateTime.count)
        #expect(Date.nowCompactString.count == Date().compactDateTime.count)
    }

    /// 回归保护：KitLogging 曾用 `static var now: String` 覆盖 Foundation 的
    /// `Date.now: Date`，导致 `Date.now.addingTimeInterval(60)` 在导入本模块后
    /// 变成类型错误。移除该覆盖后，这里必须仍然能按 Date 使用。
    @Test("Date.now 仍解析为 Foundation 的 Date")
    func foundationNowIsUnshadowed() {
        let value: Date = Date.now
        #expect(abs(value.timeIntervalSinceNow) < 60)
    }
}
