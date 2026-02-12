import Foundation
import IOKit.pwr_mgt
import MagicKit
import Observation
import OSLog
import SwiftUI

/// Anti-sleep manager: responsible for managing system power states
@MainActor
@Observable
class CaffeinateManager: SuperLog {
    nonisolated static let emoji = "🍽️"
    nonisolated static let verbose: Bool = false

    // MARK: - Singleton

    static let shared = CaffeinateManager()

    // MARK: - Properties

    /// Whether anti-sleep is currently active
    private(set) var isActive: Bool = false

    /// Currently active action type, nil if not active
    private(set) var activeAction: QuickActionType?

    /// Duration selected by the user (seconds), used for next activation or updating current activation
    var selectedDuration: TimeInterval = 0

    /// Activation start time
    private(set) var startTime: Date?

    /// Preset duration (seconds), 0 for indefinite
    private(set) var duration: TimeInterval = 0

    private(set) var mode: SleepMode = .systemAndDisplay

    /// IOKit assertion ID
    private var assertionID: IOPMAssertionID = 0

    private var displayAssertionID: IOPMAssertionID = 0

    /// Timer (for timed mode)
    private var timer: Timer?

    // MARK: - Initialization

    private init() {
        if Self.verbose {
            os_log("\(self.t)CaffeinateManager initialized")
        }
    }

    // MARK: - Public Methods

    /// 激活防休眠模式
    /// - Parameter duration: 持续时间（秒），0 表示永久
    func activate(duration: TimeInterval = 0) {
        activate(mode: .systemAndDisplay, duration: duration)
    }

    /// 激活防休眠模式并立即关闭显示器
    /// - Parameter duration: 持续时间（秒），0 表示永久
    func activateAndTurnOffDisplay(duration: TimeInterval = 0) {
        // 1. 激活防休眠（仅系统，允许显示器休眠）
        activate(mode: .systemOnly, duration: duration)

        // 2. 更新状态
        self.activeAction = .systemOnly
        self.selectedDuration = duration

        // 3. 关闭显示器
        turnOffDisplay()
    }

    /// 立即关闭显示器
    private func turnOffDisplay() {
        let task = Process()
        task.launchPath = "/usr/bin/pmset"
        task.arguments = ["displaysleepnow"]
        do {
            try task.run()
        } catch {
            os_log(.error, "\(self.t)Failed to turn off display: \(error.localizedDescription)")
        }
    }

    /// 激活指定的防休眠模式
    /// - Parameters:
    ///   - mode: 休眠模式（仅系统或系统与显示器）
    ///   - duration: 持续时间（秒），0 表示永久
    func activate(mode: SleepMode, duration: TimeInterval = 0) {
        guard !isActive else {
            if Self.verbose {
                os_log("\(self.t)Anti-sleep already active, ignoring duplicate request")
            }
            return
        }

        self.mode = mode
        let reason = String(localized: "Anti-sleep mode enabled via Wakey", table: "Caffeinate", comment: "Reason shown in system power assertions when anti-sleep is active") as NSString

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

            // If timed, start timer
            if duration > 0 {
                startTimer(duration: duration)
            }

            // Notify system to update status bar appearance
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

    /// 停止防休眠并清理资源
    func deactivate() {
        guard isActive else { return }
        
        if Self.verbose {
            os_log("\(self.t)Deactivating Caffeinate")
        }

        // 1. 释放 IOKit 断言
        if assertionID != 0 {
            IOPMAssertionRelease(assertionID)
            assertionID = 0
        }
        
        if displayAssertionID != 0 {
            IOPMAssertionRelease(displayAssertionID)
            displayAssertionID = 0
        }

        // 2. 更新状态
        isActive = false
        activeAction = nil
        startTime = nil
        duration = 0

        // 3. 停止定时器
        timer?.invalidate()
        timer = nil
    }

    /// Toggle anti-sleep state
    func toggle() {
        if isActive {
            deactivate()
        } else {
            activate(mode: mode)
        }
    }

    /// 获取自激活以来的持续时间
    /// - Returns: 持续时间（秒）
    func getActiveDuration() -> TimeInterval {
        guard let start = startTime else { return 0 }
        return Date().timeIntervalSince(start)
    }

    // MARK: - Private Methods

    /// 启动定时器
    /// - Parameter duration: 持续时间（秒）
    private func startTimer(duration: TimeInterval) {
        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.deactivate()
            }
        }
        
        if Self.verbose {
            os_log("\(self.t)Timer scheduled for \(duration)s")
        }
    }

    // MARK: - Cleanup

    deinit {
        // Note: As a @MainActor class, deinit is executed on the main thread
        // However, deinit cannot access actor-isolated properties
        //
        // Normally, resources should be cleaned up via deactivate()
        // deactivate() already cleans up:
        //   - IOKit assertions (assertionID, displayAssertionID)
        //   - Timer
        //
        // If the object is released without deactivate,
        // the system automatically cleans up IOKit assertions (when process ends)
        // Timer will also be automatically released
    }
}

// MARK: - Duration Options

extension CaffeinateManager {
    /// 休眠模式枚举
    enum SleepMode: String, CaseIterable {
        case systemOnly
        case systemAndDisplay
        
        /// 获取模式的显示名称
        var displayName: String {
            switch self {
            case .systemOnly:
                return String(localized: "Keep system awake, allow display sleep", table: "Caffeinate", comment: "Option to prevent system sleep but allow the monitor to turn off")
            case .systemAndDisplay:
                return String(localized: "Keep system awake, prevent display sleep", table: "Caffeinate", comment: "Option to prevent both system and monitor from sleeping")
            }
        }
    }

    /// 预设持续时间选项
    enum DurationOption: Hashable, Equatable {
        case indefinite
        case minutes(Int)
        case hours(Int)

        /// 获取持续时间的显示名称
        var displayName: String {
            switch self {
            case .indefinite:
                return String(localized: "Indefinite", table: "Caffeinate", comment: "Label for infinite duration")
            case let .minutes(m):
                return String(localized: "\(m) minutes", table: "Caffeinate", comment: "Label for duration in minutes")
            case let .hours(h):
                return String(localized: "\(h) hours", table: "Caffeinate", comment: "Label for duration in hours")
            }
        }

        /// 获取对应的秒数
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

    /// Quick action types
    enum QuickActionType: Equatable {
        case systemAndDisplay // Prevent sleep and keep display on
        case systemOnly // Prevent sleep and allow display to turn off
        case turnOffDisplay // Prevent sleep and turn off display immediately
    }

    /// Common duration options list
    static let commonDurations: [DurationOption] = [
        .indefinite,
        .minutes(10),
        .minutes(30),
        .hours(1),
        .hours(2),
        .hours(5),
    ]
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
