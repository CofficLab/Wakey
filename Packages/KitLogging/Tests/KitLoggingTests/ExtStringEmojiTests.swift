import Foundation
import Testing
@testable import KitLogging

/// `generateContextEmoji` 按映射表顺序返回**首个**命中的 emoji，
/// 因此当一个字符串同时命中多个关键词时，表中位置靠前者胜出。
/// 下列用例刻意覆盖这种优先级语义。
@Suite("上下文 Emoji")
struct ContextEmojiTests {
    @Test("英文关键词命中对应 emoji")
    func englishKeywords() {
        #expect("network timeout".generateContextEmoji() == "🌐")
        #expect("crash detected".generateContextEmoji() == "❌")
        #expect("memory leak".generateContextEmoji() == "📊")
        #expect("merge branch".generateContextEmoji() == "🔗")
        #expect("skip this".generateContextEmoji() == "⏭️")
        #expect("uuid generated".generateContextEmoji() == "🆔")
        #expect("visible region".generateContextEmoji() == "👀")
    }

    @Test("中文关键词命中对应 emoji")
    func chineseKeywords() {
        #expect("数据保存成功".generateContextEmoji() == "💾")
        #expect("调试模式启动".generateContextEmoji() == "🔍")
        #expect("设置用户参数".generateContextEmoji() == "⚙️")
        #expect("初始化系统配置".generateContextEmoji() == "🚩")
        #expect("合并分支".generateContextEmoji() == "🔗")
    }

    @Test("匹配忽略大小写")
    func matchingIsCaseInsensitive() {
        // lowercased 后 "HTTPResponse" 命中 "http"
        #expect("HTTPResponse".generateContextEmoji() == "🌐")
        #expect("Network".generateContextEmoji() == "🌐")
    }

    @Test("无匹配时返回默认笔记 emoji")
    func defaultEmojiWhenNoMatch() {
        #expect("zzz".generateContextEmoji() == "📝")
        #expect("".generateContextEmoji() == "📝")
        #expect("CPUUSAGE".generateContextEmoji() == "📝")
    }

    @Test("首个命中优先：data 早于 load")
    func firstMatchWinsDataOverLoad() {
        #expect("loading data".generateContextEmoji() == "💾")
        // load 单独出现时仍命中 💾
        #expect("loading".generateContextEmoji() == "💾")
    }

    @Test("首个命中优先：complete 早于 save")
    func firstMatchWinsCompleteOverSave() {
        #expect("save complete".generateContextEmoji() == "✅")
        #expect("save".generateContextEmoji() == "💾")
    }

    @Test("首个命中优先：error 早于 network")
    func firstMatchWinsErrorOverNetwork() {
        // "error" 在表中位于 "network" 之前
        #expect("network error".generateContextEmoji() == "❌")
        #expect("network timeout".generateContextEmoji() == "🌐")
    }

    @Test("首个命中优先：中文 fail 早于 network")
    func firstMatchWinsChineseFailOverNetwork() {
        // "失败"(fail) 在表中位于 "网络"(network) 之前
        #expect("网络请求失败".generateContextEmoji() == "❌")
        #expect("网络请求".generateContextEmoji() == "🌐")
    }

    @Test("首个命中优先：init 早于 manager / plugin 早于 load 的逆序")
    func firstMatchWinsInitOverManager() {
        #expect("manager init".generateContextEmoji() == "🚩")
        #expect("manager".generateContextEmoji() == "👔")
    }

    @Test("首个命中优先：load 早于 plugin")
    func firstMatchWinsLoadOverPlugin() {
        #expect("plugin loaded".generateContextEmoji() == "💾")
        #expect("plugin registry".generateContextEmoji() == "🔌")
    }

    @Test("首个命中优先：complete 早于 synchronize")
    func firstMatchWinsCompleteOverSynchronize() {
        #expect("sync completed".generateContextEmoji() == "✅")
        #expect("synchronize data".generateContextEmoji() == "💾")
        #expect("synchronize".generateContextEmoji() == "🔄")
    }

    @Test("其余代表性关键词映射")
    func representativeKeywords() {
        #expect("user tapped".generateContextEmoji() == "👆")
        #expect("click here".generateContextEmoji() == "👆")
        #expect("update version".generateContextEmoji() == "🍋")
        #expect("config file".generateContextEmoji() == "🚩")
        #expect("notification received".generateContextEmoji() == "🔔")
        #expect("push sent".generateContextEmoji() == "⬆️")
    }

    @Test("withContextEmoji 在原文前拼接 emoji")
    func withContextEmojiPrefixes() {
        #expect("network timeout".withContextEmoji == "🌐 network timeout")
        #expect("network error".withContextEmoji == "❌ network error")
    }

    @Test("withContextEmoji 对未知文本使用默认 emoji")
    func withContextEmojiFallback() {
        #expect("qqqq".withContextEmoji == "📝 qqqq")
    }
}
