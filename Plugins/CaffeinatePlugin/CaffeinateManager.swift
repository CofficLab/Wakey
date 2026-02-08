import Foundation
import IOKit.pwr_mgt
import MagicKit
import Observation
import OSLog

/// 防休眠管理器：负责管理系统电源状态
@MainActor
@Observable
class CaffeinateManager: SuperLog {
    nonisolated static let emoji = "🍽️"
    nonisolated static let verbose: Bool = false

    // MARK: - Singleton

    static let shared = CaffeinateManager()

    // MARK: - Properties

    /// 当前是否激活防休眠
    private(set) var isActive: Bool = false

    /// 当前激活的操作类型，为 nil 表示未激活
    private(set) var activeAction: QuickActionType? = nil

    /// 用户当前选择的时长（秒），用于下次激活或更新当前激活
    var selectedDuration: TimeInterval = 0

    /// 激活开始时间
    private(set) var startTime: Date?

    /// 预设持续时间（秒），0 表示永久
    private(set) var duration: TimeInterval = 0

    private(set) var mode: SleepMode = .systemAndDisplay

    /// IOKit 断言 ID
    private var assertionID: IOPMAssertionID = 0

    private var displayAssertionID: IOPMAssertionID = 0

    /// 定时器（用于定时模式）
    private var timer: Timer?

    // MARK: - Initialization

    private init() {
        if Self.verbose {
            os_log("\(self.t)CaffeinateManager 已初始化")
        }
    }

    // MARK: - 公共方法

    /// 激活防休眠
    /// - Parameter duration: 持续时间（秒），0 表示永久
    func activate(duration: TimeInterval = 0) {
        activate(mode: .systemAndDisplay, duration: duration)
    }

    /// 激活防休眠并立即关闭屏幕
    func activateAndTurnOffDisplay(duration: TimeInterval = 0) {
        // 1. 激活防休眠（仅系统，允许屏幕关闭）
        activate(mode: .systemOnly, duration: duration)
        
        // 2. 更新状态
        self.activeAction = .systemOnly
        self.selectedDuration = duration

        // 3. 关闭屏幕
        turnOffDisplay()
    }

    private func turnOffDisplay() {
        let task = Process()
        task.launchPath = "/usr/bin/pmset"
        task.arguments = ["displaysleepnow"]
        do {
            try task.run()
        } catch {
            os_log(.error, "\(self.t)关闭显示器失败: \(error.localizedDescription)")
        }
    }

    func activate(mode: SleepMode, duration: TimeInterval = 0) {
        guard !isActive else {
            if Self.verbose {
                os_log("\(self.t)防休眠已激活，忽略重复请求")
            }
            return
        }

        self.mode = mode
        let reason = "用户通过 Wakey 开启了防休眠模式" as NSString

        let systemResult = IOPMAssertionCreateWithName(
            kIOPMAssertionTypePreventUserIdleSystemSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason,
            &assertionID
        )

        var displayResult: IOReturn = kIOReturnSuccess
        if mode == .systemAndDisplay {
            displayResult = IOPMAssertionCreateWithName(
                kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
                IOPMAssertionLevel(kIOPMAssertionLevelOn),
                reason,
                &displayAssertionID
            )
        } else {
            displayAssertionID = 0
        }

        if systemResult == kIOReturnSuccess && displayResult == kIOReturnSuccess {
            isActive = true
            activeAction = (mode == .systemAndDisplay) ? .systemAndDisplay : .systemOnly
            startTime = Date()
            self.duration = duration
            self.selectedDuration = duration

            if Self.verbose {
                os_log("\(self.t)Caffeinate activated successfully with duration: \(duration)s")
            }

            // 如果设置了定时，启动定时器
            if duration > 0 {
                startTimer(duration: duration)
            }

            // 通知系统更新状态栏外观
            NotificationCenter.postRequestStatusBarAppearanceUpdate(isActive: true, source: "CaffeinatePlugin")
        } else {
            if systemResult != kIOReturnSuccess {
                os_log(.error, "\(self.t)Failed to create system sleep assertion: \(systemResult)")
            }
            if displayResult != kIOReturnSuccess {
                os_log(.error, "\(self.t)Failed to create display sleep assertion: \(displayResult)")
            }
            if assertionID != 0 {
                IOPMAssertionRelease(assertionID)
                assertionID = 0
            }
            if displayAssertionID != 0 {
                IOPMAssertionRelease(displayAssertionID)
                displayAssertionID = 0
            }
        }
    }

    /// 停用防休眠
    func deactivate() {
        guard isActive else {
            if Self.verbose {
                os_log("\(self.t)Caffeinate not active, ignoring deactivation request")
            }
            return
        }

        let systemResult = assertionID == 0 ? kIOReturnSuccess : IOPMAssertionRelease(assertionID)
        let displayResult = displayAssertionID == 0 ? kIOReturnSuccess : IOPMAssertionRelease(displayAssertionID)

        if systemResult == kIOReturnSuccess && displayResult == kIOReturnSuccess {
            isActive = false
            activeAction = nil
            startTime = nil
            duration = 0
            assertionID = 0
            displayAssertionID = 0

            // 停止定时器
            timer?.invalidate()
            timer = nil

            if Self.verbose {
                os_log("\(self.t)Caffeinate deactivated successfully")
            }

            // 通知系统恢复状态栏外观
            NotificationCenter.postRequestStatusBarAppearanceUpdate(isActive: false, source: "CaffeinatePlugin")
        } else {
            if systemResult != kIOReturnSuccess {
                os_log(.error, "\(self.t)释放系统休眠断言失败: \(systemResult)")
            }
            if displayResult != kIOReturnSuccess {
                os_log(.error, "\(self.t)释放显示休眠断言失败: \(displayResult)")
            }
        }
    }

    /// 切换防休眠状态
    func toggle() {
        if isActive {
            deactivate()
        } else {
            activate(mode: mode)
        }
    }

    /// 获取已激活的持续时间
    /// - Returns: 激活至今的时间间隔（秒），如果未激活则返回 nil
    func getActiveDuration() -> TimeInterval? {
        guard let start = startTime else { return nil }
        return Date().timeIntervalSince(start)
    }

    // MARK: - Private Methods

    /// 启动定时器
    /// - Parameter duration: 持续时间（秒）
    private func startTimer(duration: TimeInterval) {
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                if Self.verbose {
                    os_log("\(Self.t)Timer expired, deactivating caffeinate")
                }
                self.deactivate()
            }
        }
        if Self.verbose {
            os_log("\(self.t)Timer scheduled for \(duration)s")
        }
    }

    // MARK: - Cleanup

    deinit {
        // 注意：作为 @MainActor 类，deinit 在主线程执行
        // 但 deinit 不能访问 actor-isolated 属性
        //
        // 正常情况下，资源应该通过 deactivate() 清理
        // deactivate() 已经清理了：
        //   - IOKit 断言 (assertionID, displayAssertionID)
        //   - Timer
        //
        // 如果对象在没有 deactivate 的情况下被释放，
        // 系统会自动清理 IOKit 断言（进程结束时）
        // Timer 也会被自动释放
    }
}

// MARK: - Duration Options

extension CaffeinateManager {
    enum SleepMode: String, CaseIterable {
        case systemOnly
        case systemAndDisplay

        var displayName: String {
            switch self {
            case .systemOnly:
                return "阻止休眠，允许关闭屏幕"
            case .systemAndDisplay:
                return "阻止休眠，禁止关闭屏幕"
            }
        }
    }

    /// 预设的时间选项
    enum DurationOption: Hashable, Equatable {
        case indefinite
        case minutes(Int)
        case hours(Int)
        
        var displayName: String {
            switch self {
            case .indefinite:
                return "永久"
            case let .minutes(m):
                return "\(m) 分钟"
            case let .hours(h):
                return "\(h) 小时"
            }
        }
        
        var timeInterval: TimeInterval {
            switch self {
            case .indefinite:
                return 0
            case let .minutes(m):
                return TimeInterval(m * 60)
            case let .hours(h):
                return TimeInterval(h * 3600)
            }
        }
    }

    /// 快捷操作类型
    enum QuickActionType: Equatable {
        case systemAndDisplay // 防止休眠且屏幕常亮
        case systemOnly // 防止休眠且允许屏幕关闭
        case turnOffDisplay // 防止休眠且立刻关闭屏幕
    }

    /// 常用的时间选项列表
    static let commonDurations: [DurationOption] = [
        .indefinite,
        .minutes(10),
        .minutes(30),
        .hours(1),
        .hours(2),
        .hours(5),
    ]
}
