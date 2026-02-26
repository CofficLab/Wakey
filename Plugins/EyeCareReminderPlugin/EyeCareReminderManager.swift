import Foundation
import MagicKit
import Observation
import OSLog
import SwiftUI
import UserNotifications

/// Eye Care Reminder Manager: manages eye care break reminders
@MainActor
@Observable
class EyeCareReminderManager: NSObject, SuperLog {
    nonisolated static let emoji = "👁️"
    nonisolated static let verbose: Bool = true

    // MARK: - Singleton

    static let shared = EyeCareReminderManager()

    // MARK: - Properties
    
    private let userDefaultsKey = "EyeCareReminderInterval"
    private let customIntervalsKey = "EyeCareCustomIntervals"

    /// Whether break reminder is currently active
    private(set) var isActive: Bool = false

    /// Selected break interval in seconds
    private(set) var selectedInterval: TimeInterval = 60 * 60 // Default 60 minutes
    
    /// Available intervals (including defaults and custom ones)
    private(set) var availableIntervals: [IntervalOption] = []

    /// Next break time
    private(set) var nextBreakTime: Date?

    /// Break start time
    private(set) var startTime: Date?

    /// Timer for scheduling breaks
    private var timer: Timer?

    /// Today's break count
    private(set) var todayBreakCount: Int = 0

    /// Current overlay window
    private var currentOverlayWindow: EyeCareReminderOverlayWindow?

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

    private override init() {
        super.init()
        
        // Load custom intervals
        loadAvailableIntervals()
        
        // Load persisted interval
        let savedInterval = UserDefaults.standard.double(forKey: userDefaultsKey)
        if savedInterval > 0 {
            self.selectedInterval = savedInterval
        }

        if Self.verbose {
            os_log("\(self.t)EyeCareReminderManager initialized")
        }
        checkNotificationPermission()
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
        self.startTime = Date()
        scheduleNextBreak()

        if Self.verbose {
            os_log("\(self.t)Eye Care reminder started")
        }

        // Notify system to update status bar
        NotificationCenter.postRequestBreakReminderStatusUpdate(isActive: true, type: "eyeCare")
    }

    /// Stop break reminder
    func stop() {
        guard isActive else { return }

        if Self.verbose {
            os_log("\(self.t)Stopping Eye Care reminder")
        }

        timer?.invalidate()
        timer = nil
        isActive = false
        nextBreakTime = nil
        startTime = nil

        // Remove pending notifications
        // UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        // Notify system
        NotificationCenter.postRequestBreakReminderStatusUpdate(isActive: false, type: nil)
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
        if !availableIntervals.contains(option) {
            availableIntervals.append(option)
            availableIntervals.sort { $0.timeInterval < $1.timeInterval }
            saveCustomIntervals()
            
            // Auto select the newly added interval
            updateInterval(option.timeInterval)
        }
    }
    
    /// Remove an interval
    /// - Parameter option: The option to remove
    func removeInterval(_ option: IntervalOption) {
        // Don't remove default intervals
        guard !Self.commonIntervals.contains(option) else { return }

        availableIntervals.removeAll { $0 == option }
        saveCustomIntervals()

        // If currently selected interval was removed, revert to default
        if selectedInterval == option.timeInterval {
            updateInterval(Self.commonIntervals[0].timeInterval)
        }
    }

    /// Reset intervals to default
    func resetIntervals() {
        availableIntervals = Self.commonIntervals
        saveCustomIntervals()
        updateInterval(Self.commonIntervals[0].timeInterval)
    }

    /// Update break interval
    /// - Parameter interval: New interval in seconds
    func updateInterval(_ interval: TimeInterval) {
        selectedInterval = interval
        UserDefaults.standard.set(interval, forKey: userDefaultsKey)

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
        return next.timeIntervalSinceNow
    }

    // MARK: - Private Methods

    /// Schedule next break
    private func scheduleNextBreak() {
        scheduleBreak(in: selectedInterval)
    }

    /// Schedule a break after specified interval
    /// - Parameter interval: Interval in seconds
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

    /// Fire break reminder
    private func fireBreakReminder() {
        guard isActive else { return }

        if Self.verbose {
            os_log("\(self.t)Firing Eye Care reminder")
        }

        showDesktopGradient()
        todayBreakCount += 1
        scheduleNextBreak()
    }

    /// Show desktop gradient animation
    private func showDesktopGradient() {
        currentOverlayWindow = EyeCareReminderOverlayWindow()
        currentOverlayWindow?.showAndFadeOut()
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
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Persistence
    
    private func loadAvailableIntervals() {
        // Start with default intervals
        var intervals = Self.commonIntervals
        
        // Load custom intervals from UserDefaults
        if let customMinutesArray = UserDefaults.standard.array(forKey: customIntervalsKey) as? [Int] {
            let customOptions = customMinutesArray.map { IntervalOption.minutes($0) }
            // Add custom options if not already present
            for option in customOptions {
                if !intervals.contains(option) {
                    intervals.append(option)
                }
            }
        }
        
        // Sort by duration
        intervals.sort { $0.timeInterval < $1.timeInterval }
        
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
        
        UserDefaults.standard.set(customMinutesArray, forKey: customIntervalsKey)
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
            case let .minutes(m): return String(localized: "\(m) min", table: "EyeCareReminder", comment: "Label for duration in minutes")
            case let .hours(h): return String(localized: "\(h) hr", table: "EyeCareReminder", comment: "Label for duration in hours")
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

// MARK: - UNUserNotificationCenterDelegate

// extension EyeCareReminderManager: UNUserNotificationCenterDelegate {
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
