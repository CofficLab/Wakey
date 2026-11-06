import Foundation
import KitLogging
import KitReminder
import Observation
import OSLog
import SwiftUI
import UserNotifications

/// Eye Care Reminder Manager: manages eye care break reminders
@MainActor
@Observable
class EyeCareReminderManager: NSObject, SuperLog {
    nonisolated static let emoji = "👁️"
    /// 详细日志开关。生产环境保持关闭，测试中可临时打开以覆盖日志分支。
    static var verbose: Bool = false

    // MARK: - Singleton

    static let shared = EyeCareReminderManager(
        environment: SystemReminderEnvironment { kind in
            guard kind == .eyeCare else { return }
            EyeCareReminderOverlayWindow().showAndFadeOut()
        }
    )

    // MARK: - Properties

    private let userDefaultsKey = "EyeCareReminderInterval"
    private let customIntervalsKey = "EyeCareCustomIntervals"

    /// 时间 / 持久化 / 计时来源，生产环境为系统实现，测试可注入可控实现。
    private let environment: any ReminderEnvironment

    /// 「今日次数」计数器，状态落在插件专属目录。
    private let dailyCounter: DailyCounter

    /// Whether break reminder is currently active
    private(set) var isActive: Bool = false

    /// Selected break interval in seconds
    private(set) var selectedInterval: TimeInterval = EyeCareReminderManager.defaultInterval.timeInterval
    
    /// Available intervals (including defaults and custom ones)
    private(set) var availableIntervals: [IntervalOption] = []

    /// Next break time
    private(set) var nextBreakTime: Date?

    /// Break start time
    private(set) var startTime: Date?

    /// Timer for scheduling breaks
    private var timer: ReminderTimerToken?

    /// 今日休息次数。
    ///
    /// 计数与所属日期一起持久化：跨零点后自动归零，重启 App 后仍在。
    /// 状态落在插件专属目录的 Binary Plist（见 `ReminderStateStore`）。
    var todayBreakCount: Int { dailyCounter.todayCount }

    /// Notification permission status
    enum PermissionStatus {
        case notDetermined
        case authorized
        case denied
    }

    /// Current notification permission status
    private(set) var permissionStatus: PermissionStatus = .notDetermined

    /// Notification permission granted
    private(set) var notificationPermissionGranted: Bool = false

    // MARK: - Initialization

    init(environment: any ReminderEnvironment) {
        self.environment = environment
        self.dailyCounter = DailyCounter(
            store: environment.stateStore,
            keyPrefix: "EyeCareReminder"
        )
        super.init()

        // Load custom intervals
        loadAvailableIntervals()

        // Load persisted interval
        let savedInterval = environment.savedInterval(forKey: userDefaultsKey)
        if savedInterval > 0 {
            self.selectedInterval = savedInterval
        }

        if Self.verbose {
            os_log("\(self.t)EyeCareReminderManager initialized")
        }
        checkNotificationPermission()
    }

    /// 宿主在 `onBoot` 阶段注入插件专属的状态存储目录。
    ///
    /// - Parameter directory: 插件数据目录（`StorageProviding.pluginDataDirectory(for:)`）。
    func attachStateStore(directory: URL) {
        environment.attachStateStore(directory: directory)
    }

    // MARK: - Public Methods

    /// Check and request notification permission
    func checkNotificationPermission() {
        // No longer need system notification permission
        self.permissionStatus = .authorized
        self.notificationPermissionGranted = true
    }

    /// Open System Settings for Notifications
    func openNotificationSettings() {
        // No longer need to open system settings
    }

    /// Start break reminder
    func start() {
        guard !isActive else { return }

        self.isActive = true
        self.startTime = environment.now()
        scheduleNextBreak()

        if Self.verbose {
            os_log("\(self.t)Eye Care reminder started")
        }
    }

    /// Stop break reminder
    func stop() {
        guard isActive else { return }

        if Self.verbose {
            os_log("\(self.t)Stopping Eye Care reminder")
        }

        environment.cancel(timer)
        timer = nil
        isActive = false
        nextBreakTime = nil
        startTime = nil

        // Remove pending notifications
        // UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    /// Snooze for specified minutes
    /// - Parameter minutes: Minutes to snooze
    func snooze(minutes: Int) {
        guard isActive else { return }

        if Self.verbose {
            os_log("\(self.t)Snoozing for \(minutes) minutes")
        }

        let interval = TimeInterval(minutes * 60)
        scheduleBreak(in: interval)
    }

    /// Add a custom interval
    /// - Parameter minutes: Duration in minutes
    func addCustomInterval(minutes: Int) {
        let option = IntervalOption.minutes(minutes)
        // 按时长（秒）判重：自定义 60 分钟与预设 1 小时是同一时长，
        // 同时存在会让选择器渲染出两个按钮且同时高亮。
        guard !availableIntervals.contains(where: { $0.timeInterval == option.timeInterval }) else {
            return
        }
        availableIntervals.append(option)
        availableIntervals.sort { $0.timeInterval < $1.timeInterval }
        saveCustomIntervals()

        // Auto select the newly added interval
        updateInterval(option.timeInterval)
    }
    
    /// Remove an interval
    /// - Parameter option: The option to remove
    func removeInterval(_ option: IntervalOption) {
        // Don't remove default intervals
        guard !Self.commonIntervals.contains(option) else { return }

        availableIntervals.removeAll { $0 == option }
        saveCustomIntervals()

        // If the selected interval no longer exists, fall back to the default.
        if !availableIntervals.contains(where: { $0.timeInterval == selectedInterval }) {
            updateInterval(Self.defaultInterval.timeInterval)
        }
    }

    /// Reset intervals to default
    func resetIntervals() {
        availableIntervals = Self.commonIntervals
        saveCustomIntervals()
        updateInterval(Self.defaultInterval.timeInterval)
    }

    /// Update break interval
    /// - Parameter interval: New interval in seconds
    func updateInterval(_ interval: TimeInterval) {
        selectedInterval = interval
        environment.save(interval: interval, forKey: userDefaultsKey)

        // Reschedule if active
        if isActive {
            scheduleNextBreak()
        }

        if Self.verbose {
            os_log("\(self.t)Eye Care interval updated to: \(interval)s")
        }
    }

    /// Get time until next break
    /// - Returns: Time interval in seconds, nil if not active
    func timeUntilNextBreak() -> TimeInterval? {
        guard let next = nextBreakTime else { return nil }
        return next.timeIntervalSince(environment.now())
    }

    // MARK: - Private Methods

    /// Schedule next break
    private func scheduleNextBreak() {
        scheduleBreak(in: selectedInterval)
    }

    /// Schedule a break after specified interval
    /// - Parameter interval: Interval in seconds
    private func scheduleBreak(in interval: TimeInterval) {
        environment.cancel(timer)
        nextBreakTime = environment.now().addingTimeInterval(interval)
        timer = environment.schedule(after: interval) { [weak self] in
            self?.fireBreakReminder()
        }
        scheduleNotification(in: interval)
    }

    /// Fire break reminder
    private func fireBreakReminder() {
        guard isActive else { return }

        if Self.verbose {
            os_log("\(self.t)Firing Eye Care reminder")
        }

        showDesktopGradient()
        dailyCounter.increment()
        scheduleNextBreak()
    }

    /// Show desktop gradient animation
    private func showDesktopGradient() {
        environment.presentReminderOverlay(kind: .eyeCare)
    }

    /// Schedule system notification
    /// - Parameter interval: Interval in seconds
    private func scheduleNotification(in interval: TimeInterval) {
        // No system notification needed
    }

    /// Request notification permission
    private func requestNotificationPermission() {
        // No longer need to request permission
        self.notificationPermissionGranted = true
        self.permissionStatus = .authorized
    }

    /// Cleanup resources
    func cleanup() {
        environment.cancel(timer)
        timer = nil
    }

    // MARK: - Persistence
    
    private func loadAvailableIntervals() {
        // Start with default intervals
        var intervals = Self.commonIntervals

        // Load custom intervals from UserDefaults
        if let customMinutesArray = environment.savedCustomIntervals(forKey: customIntervalsKey) {
            let customOptions = customMinutesArray.map { IntervalOption.minutes($0) }
            // Add custom options if not already present
            for option in customOptions {
                if !intervals.contains(option) {
                    intervals.append(option)
                }
            }
        }

        // 按时长（秒）去重：自定义 60 分钟不应与预设 1 小时并存，
        // 否则选择器会渲染出两个按钮且同时高亮。
        intervals = ReminderIntervalList.deduped(intervals) { $0.timeInterval }

        self.availableIntervals = intervals
    }
    
    private func saveCustomIntervals() {
        // Extract custom intervals (those not in commonIntervals)
        let customOptions = availableIntervals.filter { !Self.commonIntervals.contains($0) }
        
        // Convert to minutes for storage
        let customMinutesArray = customOptions.map { option -> Int in
            switch option {
            case .minutes(let m): return m
            case .hours(let h): return h * 60
            }
        }
        
        environment.saveCustomIntervals(customMinutesArray, forKey: customIntervalsKey)
    }
}

// MARK: - Interval Options

extension EyeCareReminderManager {
    enum IntervalOption: Hashable, Equatable, Identifiable {
        case minutes(Int)
        case hours(Int)

        var id: String {
            switch self {
            case let .minutes(m): return "m\(m)"
            case let .hours(h): return "h\(h)"
            }
        }

        var displayName: String {
            switch self {
            case let .minutes(m): return String(format: String(localized: "%lld min", table: "EyeCareReminder", bundle: .module, comment: "Label for duration in minutes"), m)
            case let .hours(h): return String(format: String(localized: "%lld hr", table: "EyeCareReminder", bundle: .module, comment: "Label for duration in hours"), h)
            }
        }

        var timeInterval: TimeInterval {
            switch self {
            case let .minutes(m): return TimeInterval(m * 60)
            case let .hours(h): return TimeInterval(h * 3600)
            }
        }
    }

    /// 护眼提醒的预设间隔。
    ///
    /// 护眼使用独立于另外两个提醒的一套预设：20 分钟是护眼场景的推荐
    /// 节奏（也正是插件描述对外承诺的间隔），把它放进预设才能让
    /// 「描述 = 默认值 = 可选项」三者一致。
    static let commonIntervals: [IntervalOption] = [
        .minutes(10),
        .minutes(20),
        .minutes(30),
        .hours(1),
        .hours(2),
        .hours(3),
    ]

    /// 护眼提醒的默认间隔。
    ///
    /// 首次启动、移除当前选中项、恢复默认时都回退到该值；
    /// 插件描述中的「每 20 分钟」也对应它。
    static let defaultInterval: IntervalOption = .minutes(20)
}
