import Foundation
import Testing
@testable import KitLogging

@Suite("QualityOfService 描述")
struct QualityOfServiceDescriptionTests {
    @Test("带名称时输出 emoji + 名称")
    func descriptionsWithName() {
        #expect(QualityOfService.userInteractive.description() == "🔥 UserInteractive")
        #expect(QualityOfService.userInitiated.description() == "2️⃣ UserInitiated")
        #expect(QualityOfService.default.description() == "3️⃣ Default")
        #expect(QualityOfService.utility.description() == "4️⃣ Utility")
        #expect(QualityOfService.background.description() == "5️⃣ Background")
    }

    @Test("不带名称时仅输出 emoji")
    func descriptionsWithoutName() {
        #expect(QualityOfService.userInteractive.description(withName: false) == "🔥")
        #expect(QualityOfService.userInitiated.description(withName: false) == "2️⃣")
        #expect(QualityOfService.default.description(withName: false) == "3️⃣")
        #expect(QualityOfService.utility.description(withName: false) == "4️⃣")
        #expect(QualityOfService.background.description(withName: false) == "5️⃣")
    }

    @Test("默认参数等价于显式传 true")
    func defaultArgumentMatchesTrue() {
        #expect(QualityOfService.utility.description() == QualityOfService.utility.description(withName: true))
    }
}

@Suite("SuperLog 前缀")
struct SuperLogTests {
    private struct Sample: SuperLog {
        nonisolated static let emoji = "🧪"
    }

    private struct NoEmoji: SuperLog {}

    @Test("t 由 QoS 标记、emoji、补齐后的类型名和分隔符组成")
    func prefixLayout() {
        let prefix = Sample.t
        // 形如 "🔥 | 🧪 Sample                       | "
        #expect(prefix.contains("🧪"))
        #expect(prefix.contains("Sample"))
        // 首段即当前线程 QoS 的无名称描述
        #expect(prefix.hasPrefix(Thread.currentQosDescription))
        #expect(prefix.hasSuffix("| "))
    }

    @Test("类型名补齐到 27 字符")
    func authorIsPadded() {
        #expect(Sample.author == "Sample")
        // 名字后跟随空格补齐
        #expect(Sample.t.contains("Sample" + String(repeating: " ", count: 27 - "Sample".count)))
    }

    @Test("未自定义 emoji 时按类型名生成")
    func emojiDefaultsToGenerated() {
        // NoEmoji 走 generateContextEmoji 兜底，至少返回非空 emoji
        #expect(!NoEmoji.emoji.isEmpty)
        #expect(NoEmoji.t.contains(NoEmoji.emoji))
    }

    @Test("author 去掉泛型参数")
    func authorStripsGenerics() {
        #expect(Box<Int>.author == "Box")
        #expect(Sample.author == "Sample")
    }

    @Test("r() 为原因文本添加箭头前缀")
    func reasonPrefixes() {
        #expect(Sample().r("bad input") == " ➡️ bad input")
        #expect(Sample().makeReason("bad input") == " ➡️ bad input")
    }

    @Test("onAppear / onInit 前缀带各自标记")
    func lifecyclePrefixes() {
        #expect(Sample.onAppear.hasSuffix("📺 OnAppear "))
        #expect(Sample.onInit.hasSuffix("🚩 Init "))
    }

    @Test("实例属性代理到静态实现")
    func instancePropertiesMirrorStaticOnes() {
        let sample = Sample()
        #expect(sample.author == Sample.author)
        #expect(sample.className == "Sample")
        #expect(sample.a == Sample.a)
        #expect(sample.i == Sample.i)
        #expect(sample.t == Sample.t)
    }

    @Test("isMain 反映当前线程")
    func isMainReflectsCurrentThread() {
        // Swift Testing 在 worker 线程执行用例，此处只校验与 Thread 状态一致
        let sample = Sample()
        #expect(sample.isMain == Thread.isMainThread)
    }

    @Test("currentQosDescription 是当前线程 QoS 的无名称形式")
    func currentQosDescriptionMatchesThread() {
        let expected = Thread.current.qualityOfService.description(withName: false)
        #expect(Thread.currentQosDescription == expected)
    }

    private struct Box<T>: SuperLog {}
}
