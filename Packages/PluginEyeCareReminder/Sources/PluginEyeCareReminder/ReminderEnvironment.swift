import Foundation

/// 提醒弹层类型，用于区分护眼 / 喝水 / 拉伸三种语义。
public enum ReminderOverlayKind: String, Sendable {
    case eyeCare
    case hydration
    case stretch
}

/// 计时器句柄，用于取消尚未触发的回调。
public struct ReminderTimerToken: Hashable, Sendable {
    let id: UInt64
}

/// 抽象「休息提醒」所需的时间、持久化、计时与弹窗能力。
///
/// 三个 Reminder 插件（护眼 / 喝水 / 拉伸）原本直接依赖
/// `Date()`、`UserDefaults.standard`、`Timer.scheduledTimer`
/// 与真实的 NSWindow 弹层，导致 `start` / `stop` / `snooze` /
/// 间隔持久化这些真正会出错的逻辑无法在测试进程中验证
/// （单例 + 硬编码系统依赖 + 无窗口环境）。
///
/// 抽出该协议后，生产环境仍由 `SystemReminderEnvironment` 提供真实实现，
/// 行为完全不变；测试可注入可控实现精确推进时间与触发回调。
@MainActor
public protocol ReminderEnvironment: AnyObject {
    /// 当前时间
    func now() -> Date

    /// 读取已持久化的选中间隔（秒）；无记录时返回 0
    func savedInterval(forKey key: String) -> TimeInterval

    /// 写入选中间隔（秒）
    func save(interval: TimeInterval, forKey key: String)

    /// 读取已持久化的自定义间隔（分钟）
    func savedCustomIntervals(forKey key: String) -> [Int]?

    /// 写入自定义间隔（分钟）
    func saveCustomIntervals(_ minutes: [Int], forKey key: String)

    /// 在指定延迟后触发回调；返回的 token 用于取消
    func schedule(after delay: TimeInterval, handler: @escaping () -> Void) -> ReminderTimerToken

    /// 取消尚未触发的计时
    func cancel(_ token: ReminderTimerToken?)

    /// 展示休息提醒弹层。生产环境创建真实覆盖窗口；
    /// 测试中可替换为仅计数的实现，避免无窗口进程崩溃。
    func presentReminderOverlay(kind: ReminderOverlayKind)
}

/// 生产环境实现：直接使用系统 API，行为与改造前一致。
@MainActor
public final class SystemReminderEnvironment: ReminderEnvironment {
    public static let shared = SystemReminderEnvironment()

    private var nextToken: UInt64 = 0
    private var timers: [UInt64: Timer] = [:]

    private init() {}

    public func now() -> Date { Date() }

    public func savedInterval(forKey key: String) -> TimeInterval {
        UserDefaults.standard.double(forKey: key)
    }

    public func save(interval: TimeInterval, forKey key: String) {
        UserDefaults.standard.set(interval, forKey: key)
    }

    public func savedCustomIntervals(forKey key: String) -> [Int]? {
        UserDefaults.standard.array(forKey: key) as? [Int]
    }

    public func saveCustomIntervals(_ minutes: [Int], forKey key: String) {
        UserDefaults.standard.set(minutes, forKey: key)
    }

    public func schedule(after delay: TimeInterval, handler: @escaping () -> Void) -> ReminderTimerToken {
        nextToken += 1
        let token = ReminderTimerToken(id: nextToken)
        let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            self?.timers[token.id] = nil
            handler()
        }
        timers[token.id] = timer
        return token
    }

    public func cancel(_ token: ReminderTimerToken?) {
        guard let token else { return }
        timers[token.id]?.invalidate()
        timers[token.id] = nil
    }

    public func presentReminderOverlay(kind: ReminderOverlayKind) {
        // 生产环境创建真实覆盖窗口；只有 .eyeCare 在本模块内实现，
        // 其它类型由对应插件自行处理。
        guard kind == .eyeCare else { return }
        let window = EyeCareReminderOverlayWindow()
        window.showAndFadeOut()
    }
}
