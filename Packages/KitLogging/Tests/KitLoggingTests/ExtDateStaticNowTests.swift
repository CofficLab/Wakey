import Foundation
import Testing
@testable import KitLogging

/// KitLogging 为 `Date` 扩展了 `static var now: String`，
/// 与 Foundation 的 `Date.now: Date` 同名。
/// 当前模块内的扩展优先于导入模块，因此这里用显式类型标注取到字符串版本，
/// 既消除了歧义，也确认了 KitLogging 的实现确实生效。
@Suite("Date 静态 now")
struct DateStaticNowTests {
    @Test("Date.now 输出 yyyy-MM-dd HH:mm:ss")
    func staticNowFormats() {
        let value: String = Date.now
        #expect(value.count == 19)
        #expect(value.contains("-"))
        #expect(value.contains(":"))
    }

    @Test("Date.nowCompact 输出 14 位紧凑格式")
    func staticNowCompactFormats() {
        let value: String = Date.nowCompact
        #expect(value.count == 14)
        #expect(value.allSatisfy { $0.isNumber })
    }

    @Test("静态形式与实例形式使用同一套格式")
    func staticFormsMatchInstanceForms() {
        // 分别取样以避免跨秒导致字符串不同，只比较格式特征。
        let full: String = Date.now
        let compact: String = Date.nowCompact
        #expect(full.count == Date().fullDateTime.count)
        #expect(compact.count == Date().compactDateTime.count)
    }
}
