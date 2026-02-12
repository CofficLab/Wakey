import Foundation
import MagicKit
import Observation
import OSLog
import UserNotifications
import SwiftUI

/// Eye Care Reminder Manager: manages eye care break reminders
@MainActor
@Observable
class EyeCareReminderManager: NSObject, SuperLog {
    nonisolated static let emoji = "👁️"
    nonisolated static let verbose: Bool = true

    // MARK: - Singleton

    static let shared = EyeCareReminderManager()

    // MARK: - Properties

    /// Whether break reminder is currently active
    private(set) var isActive: Bool = false

    /// Selected break interval in seconds
    private(set) var selectedInterval: TimeInterval = 20 * 60 // Default 20 minutes

    /// Next break time
    private(set) var nextBreakTime: Date?

    /// Break start time
    private(set) var startTime: Date?

    /// Timer for scheduling breaks
    private var timer: Timer?

    /// Today's break count
    private(set) var todayBreakCount: Int = 0

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
        if Self.verbose {
            os_log("\(self.t)EyeCareReminderManager initialized")
        }
        checkNotificationPermission()
    }

    // MARK: - Public Methods

    /// Check and request notification permission
    func checkNotificationPermission() {
        Task {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            
            let status = settings.authorizationStatus
            
            await MainActor.run {
                switch status {
                case .notDetermined:
                    self.permissionStatus = .notDetermined
                    self.requestNotificationPermission()
                case .authorized, .provisional, .ephemeral:
                    self.permissionStatus = .authorized
                    self.notificationPermissionGranted = true
                case .denied:
                    self.permissionStatus = .denied
                    self.notificationPermissionGranted = false
                @unknown default:
                    self.permissionStatus = .notDetermined
                }
            }
        }
    }

    /// Open System Settings for Notifications
    func openNotificationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
            NSWorkspace.shared.open(url)
        }
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
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

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

    /// Update break interval
    /// - Parameter interval: New interval in seconds
    func updateInterval(_ interval: TimeInterval) {
        selectedInterval = interval

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
        let overlayWindow = EyeCareReminderOverlayWindow()
        overlayWindow.showAndFadeOut()
    }

    /// Schedule system notification
    /// - Parameter interval: Interval in seconds
    private func scheduleNotification(in interval: TimeInterval) {
        guard notificationPermissionGranted else { return }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "Time for a Break!", table: "EyeCareReminder")
        content.body = String(localized: "Look away from the screen for 20 seconds to rest your eyes.", table: "EyeCareReminder")
        content.sound = .default
        content.categoryIdentifier = "EYE_CARE_REMINDER"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                os_log(.error, "Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    /// Request notification permission
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { [weak self] granted, error in
            Task { @MainActor in
                self?.notificationPermissionGranted = granted
                self?.permissionStatus = granted ? .authorized : .denied
            }
        }
        center.delegate = self
    }

    /// Cleanup resources
    func cleanup() {
        timer?.invalidate()
        timer = nil
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

// MARK: - Interval Options

extension EyeCareReminderManager {
    enum IntervalOption: Hashable, Equatable, Identifiable {
        case minutes(Int)
        case hours(Int)

        var id: String {
            switch self {
            case .minutes(let m): return "m\(m)"
            case .hours(let h): return "h\(h)"
            }
        }

        var displayName: String {
            switch self {
            case .minutes(let m): return String(localized: "\(m) min", table: "EyeCareReminder")
            case .hours(let h): return String(localized: "\(h) hr", table: "EyeCareReminder")
            }
        }

        var timeInterval: TimeInterval {
            switch self {
            case .minutes(let m): return TimeInterval(m * 60)
            case .hours(let h): return TimeInterval(h * 3600)
            }
        }
    }

    static let commonIntervals: [IntervalOption] = [
        .minutes(10),
        .minutes(20),
        .minutes(30),
        .hours(1),
        .hours(2),
    ]
}

// MARK: - UNUserNotificationCenterDelegate

extension EyeCareReminderManager: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let actionIdentifier = response.actionIdentifier
        Task { @MainActor in
            if actionIdentifier == UNNotificationDefaultActionIdentifier {
                self.snooze(minutes: 5)
            }
        }
        completionHandler()
    }
}
