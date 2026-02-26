import Foundation
import MagicKit
import Observation
import OSLog
import SwiftUI
import UserNotifications

/// Stretch Reminder Manager: manages stretch break reminders
@MainActor
@Observable
class StretchReminderManager: NSObject, SuperLog {
    nonisolated static let emoji = "🏃"
    nonisolated static let verbose: Bool = true

    static let shared = StretchReminderManager()
    
    private let userDefaultsKey = "StretchReminderInterval"
    private let customIntervalsKey = "StretchCustomIntervals"

    private(set) var isActive: Bool = false
    private(set) var selectedInterval: TimeInterval = 60 * 60 // Default 1 hour
    private(set) var availableIntervals: [IntervalOption] = []
    private(set) var nextBreakTime: Date?
    private(set) var startTime: Date?
    private var timer: Timer?
    private(set) var todayBreakCount: Int = 0

    enum PermissionStatus {
        case notDetermined
        case authorized
        case denied
    }

    private(set) var permissionStatus: PermissionStatus = .notDetermined
    private(set) var notificationPermissionGranted: Bool = false
    private var currentOverlayWindow: StretchReminderOverlayWindow?

    override private init() {
        super.init()
        
        // Load custom intervals
        loadAvailableIntervals()
        
        // Load persisted interval
        let savedInterval = UserDefaults.standard.double(forKey: userDefaultsKey)
        if savedInterval > 0 {
            self.selectedInterval = savedInterval
        }

        if Self.verbose {
            os_log("\(self.t)StretchReminderManager initialized")
        }
        checkNotificationPermission()
    }

    func checkNotificationPermission() {
        // No longer need system notification permission
        self.permissionStatus = .authorized
        self.notificationPermissionGranted = true
    }

    func openNotificationSettings() {
        // No longer need to open system settings
    }

    func start() {
        guard !isActive else { return }
        self.isActive = true
        self.startTime = Date()
        scheduleNextBreak()
        NotificationCenter.postRequestBreakReminderStatusUpdate(isActive: true, type: "stretch")
    }

    func stop() {
        guard isActive else { return }
        timer?.invalidate()
        timer = nil
        isActive = false
        nextBreakTime = nil
        startTime = nil
        // UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        NotificationCenter.postRequestBreakReminderStatusUpdate(isActive: false, type: nil)
    }

    func snooze(minutes: Int) {
        guard isActive else { return }
        let interval = TimeInterval(minutes * 60)
        scheduleBreak(in: interval)
    }

    func addCustomInterval(minutes: Int) {
        let option = IntervalOption.minutes(minutes)
        if !availableIntervals.contains(option) {
            availableIntervals.append(option)
            availableIntervals.sort { $0.timeInterval < $1.timeInterval }
            saveCustomIntervals()
            
            // Auto select the newly added interval
            updateInterval(option.timeInterval)
        }
    }
    
    func removeInterval(_ option: IntervalOption) {
        // Don't remove default intervals
        guard !Self.commonIntervals.contains(option) else { return }
        
        availableIntervals.removeAll { $0 == option }
        saveCustomIntervals()
        
        // If currently selected interval was removed, revert to default
        if selectedInterval == option.timeInterval {
            updateInterval(Self.commonIntervals[2].timeInterval) // Default to 1 hour
        }
    }

    func updateInterval(_ interval: TimeInterval) {
        selectedInterval = interval
        UserDefaults.standard.set(interval, forKey: userDefaultsKey)
        if isActive {
            scheduleNextBreak()
        }
    }

    func timeUntilNextBreak() -> TimeInterval? {
        guard let next = nextBreakTime else { return nil }
        return next.timeIntervalSinceNow
    }

    private func scheduleNextBreak() {
        scheduleBreak(in: selectedInterval)
    }

    private func scheduleBreak(in interval: TimeInterval) {
        timer?.invalidate()
        nextBreakTime = Date().addingTimeInterval(interval)
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.fireBreakReminder()
            }
        }
        scheduleNotification(in: interval)
    }

    private func fireBreakReminder() {
        guard isActive else { return }
        showDesktopGradient()
        todayBreakCount += 1
        scheduleNextBreak()
    }

    private func showDesktopGradient() {
        currentOverlayWindow = StretchReminderOverlayWindow()
        currentOverlayWindow?.showAndFadeOut()
    }

    private func scheduleNotification(in interval: TimeInterval) {
        // No system notification needed
    }

    private func requestNotificationPermission() {
        // No longer need to request permission
        self.notificationPermissionGranted = true
        self.permissionStatus = .authorized
    }

    func cleanup() {
        timer?.invalidate()
        timer = nil
    }

    private func loadAvailableIntervals() {
        var intervals = Self.commonIntervals
        
        // Load custom intervals from UserDefaults
        if let customMinutes = UserDefaults.standard.array(forKey: customIntervalsKey) as? [Int] {
            let customOptions = customMinutes.map { IntervalOption.minutes($0) }
            for option in customOptions {
                if !intervals.contains(option) {
                    intervals.append(option)
                }
            }
        }
        
        intervals.sort { $0.timeInterval < $1.timeInterval }
        self.availableIntervals = intervals
    }
    
    private func saveCustomIntervals() {
        let customOptions = availableIntervals.filter { !Self.commonIntervals.contains($0) }
        let customMinutes = customOptions.map { option -> Int in
            switch option {
            case .minutes(let m): return m
            case .hours(let h): return h * 60
            }
        }
        UserDefaults.standard.set(customMinutes, forKey: customIntervalsKey)
    }
}

extension StretchReminderManager {
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
            case let .minutes(m): return "\(m) min"
            case let .hours(h): return "\(h) hr"
            }
        }

        var timeInterval: TimeInterval {
            switch self {
            case let .minutes(m): return TimeInterval(m * 60)
            case let .hours(h): return TimeInterval(h * 3600)
            }
        }
    }

    static let commonIntervals: [IntervalOption] = [
        .minutes(10),
        .minutes(30),
        .hours(1),
        .hours(2),
        .hours(3),
    ]
}

// extension StretchReminderManager: UNUserNotificationCenterDelegate {
//    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        completionHandler([.banner, .sound])
//    }
//
//    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        let actionIdentifier = response.actionIdentifier
//        Task { @MainActor in
//            if actionIdentifier == UNNotificationDefaultActionIdentifier {
//                self.snooze(minutes: 5)
//            }
//        }
//        completionHandler()
//    }
// }

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
}
