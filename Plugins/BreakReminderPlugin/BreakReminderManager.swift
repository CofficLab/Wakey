import Foundation
import MagicKit
import Observation
import OSLog
import UserNotifications
import SwiftUI

/// Break Reminder Manager: manages health break reminders
@MainActor
@Observable
class BreakReminderManager: NSObject, SuperLog {
    nonisolated static let emoji = "💚"
    nonisolated static let verbose: Bool = true

    // MARK: - Singleton

    static let shared = BreakReminderManager()

    // MARK: - Properties

    /// Whether break reminder is currently active
    private(set) var isActive: Bool = false

    /// Currently selected break type
    private(set) var currentType: BreakType = .eyeCare

    /// Selected break interval in seconds
    private(set) var selectedInterval: TimeInterval = BreakType.eyeCare.defaultInterval

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
            os_log("\(self.t)BreakReminderManager initialized")
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
                    if Self.verbose {
                        os_log("\(self.t)Notification permission denied. User needs to enable it in System Settings.")
                    }
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
    /// - Parameter type: Break type
    func start(type: BreakType) {
        guard !isActive else {
            if Self.verbose {
                os_log("\(self.t)Break reminder already active, updating type")
            }
            updateType(type)
            return
        }

        self.currentType = type
        self.selectedInterval = type.defaultInterval
        self.isActive = true
        self.startTime = Date()
        scheduleNextBreak()

        if Self.verbose {
            os_log("\(self.t)Break reminder started with type: \(type.displayName)")
        }

        // Notify system to update status bar
        NotificationCenter.postRequestBreakReminderStatusUpdate(isActive: true, type: type.id)
    }

    /// Stop break reminder
    func stop() {
        guard isActive else { return }

        if Self.verbose {
            os_log("\(self.t)Stopping break reminder")
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

    /// Pause break reminder
    func pause() {
        guard isActive else { return }

        timer?.invalidate()
        timer = nil
        nextBreakTime = nil

        if Self.verbose {
            os_log("\(self.t)Break reminder paused")
        }
    }

    /// Resume break reminder
    func resume() {
        guard isActive, nextBreakTime == nil else { return }

        scheduleNextBreak()

        if Self.verbose {
            os_log("\(self.t)Break reminder resumed")
        }
    }

    /// Skip to next break
    func skip() {
        guard isActive else { return }

        if Self.verbose {
            os_log("\(self.t)Skipping to next break")
        }

        scheduleNextBreak()
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

    /// Update break type
    /// - Parameter type: New break type
    func updateType(_ type: BreakType) {
        guard isActive else { return }

        self.currentType = type
        self.selectedInterval = type.defaultInterval

        // Reschedule with new interval
        scheduleNextBreak()

        if Self.verbose {
            os_log("\(self.t)Break type updated to: \(type.displayName)")
        }

        NotificationCenter.postRequestBreakReminderStatusUpdate(isActive: true, type: type.id)
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
            os_log("\(self.t)Break interval updated to: \(interval)s")
        }
    }

    /// Get time until next break
    /// - Returns: Time interval in seconds, nil if not active
    func timeUntilNextBreak() -> TimeInterval? {
        guard let next = nextBreakTime else { return nil }
        return next.timeIntervalSinceNow
    }

    /// Get active duration
    /// - Returns: Time interval since start, nil if not active
    func getActiveDuration() -> TimeInterval? {
        guard let start = startTime else { return nil }
        return Date().timeIntervalSince(start)
    }

    // MARK: - Private Methods

    /// Schedule next break
    private func scheduleNextBreak() {
        scheduleBreak(in: selectedInterval)
    }

    /// Schedule a break after specified interval
    /// - Parameter interval: Interval in seconds
    private func scheduleBreak(in interval: TimeInterval) {
        // Invalidate existing timer
        timer?.invalidate()

        // Calculate next break time
        nextBreakTime = Date().addingTimeInterval(interval)

        // Create timer
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.fireBreakReminder()
            }
        }

        // Schedule notification
        scheduleNotification(in: interval)

        if Self.verbose {
            let nextTime = nextBreakTime?.formatted(date: .omitted, time: .standard) ?? ""
            os_log("\(self.t)Next break scheduled at: \(nextTime)")
        }
    }

    /// Fire break reminder
    private func fireBreakReminder() {
        guard isActive else { return }

        if Self.verbose {
            os_log("\(self.t)Firing break reminder for: \(self.currentType.displayName)")
        }

        // Show desktop gradient
        showDesktopGradient()

        // Increment break count
        todayBreakCount += 1

        // Schedule next break automatically
        scheduleNextBreak()
    }

    /// Show desktop gradient animation
    private func showDesktopGradient() {
        // Create overlay window with gradient animation
        let overlayWindow = BreakReminderOverlayWindow(type: self.currentType)
        overlayWindow.showAndFadeOut()
    }

    /// Schedule system notification
    /// - Parameter interval: Interval in seconds
    private func scheduleNotification(in interval: TimeInterval) {
        guard notificationPermissionGranted else { return }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "Time for a Break!", table: "BreakReminder")
        content.body = currentType.reminderMessage
        content.sound = .default
        content.categoryIdentifier = "BREAK_REMINDER"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                os_log(.error, "\(self.t)Failed to schedule notification: \(error.localizedDescription)")
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
                if let error = error {
                    os_log(.error, "\(self?.t ?? "")Notification permission error: \(error.localizedDescription)")
                }
            }
        }

        // Set delegate
        center.delegate = self
    }

    // MARK: - Cleanup

    /// Cleanup resources (call this before deallocating)
    func cleanup() {
        timer?.invalidate()
        timer = nil
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

// MARK: - Break Type

extension BreakReminderManager {
    /// Break reminder types
    enum BreakType: String, CaseIterable, Identifiable {
        case eyeCare
        case stretch
        case hydration

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .eyeCare:
                return String(localized: "Eye Care", table: "BreakReminder")
            case .stretch:
                return String(localized: "Stretch", table: "BreakReminder")
            case .hydration:
                return String(localized: "Hydration", table: "BreakReminder")
            }
        }

        var icon: String {
            switch self {
            case .eyeCare:
                return "eye.fill"
            case .stretch:
                return "figure.stand"
            case .hydration:
                return "drop.fill"
            }
        }

        var color: Color {
            switch self {
            case .eyeCare:
                return .green
            case .stretch:
                return .orange
            case .hydration:
                return .blue
            }
        }

        var defaultInterval: TimeInterval {
            switch self {
            case .eyeCare:
                return 20 * 60      // 20 minutes
            case .stretch:
                return 60 * 60      // 1 hour
            case .hydration:
                return 2 * 60 * 60  // 2 hours
            }
        }

        var reminderMessage: String {
            switch self {
            case .eyeCare:
                return String(localized: "Look away from the screen for 20 seconds to rest your eyes.", table: "BreakReminder")
            case .stretch:
                return String(localized: "Time to stand up and stretch your body.", table: "BreakReminder")
            case .hydration:
                return String(localized: "Don't forget to drink some water!", table: "BreakReminder")
            }
        }

        var description: String {
            switch self {
            case .eyeCare:
                return String(localized: "Rest your eyes every 20 minutes", table: "BreakReminder")
            case .stretch:
                return String(localized: "Move your body every hour", table: "BreakReminder")
            case .hydration:
                return String(localized: "Stay hydrated every 2 hours", table: "BreakReminder")
            }
        }
    }

    /// Interval options
    enum IntervalOption: Hashable, Equatable, Identifiable {
        case minutes(Int)
        case hours(Int)

        var id: String {
            switch self {
            case .minutes(let m):
                return "m\(m)"
            case .hours(let h):
                return "h\(h)"
            }
        }

        var displayName: String {
            switch self {
            case .minutes(let m):
                return String(localized: "\(m) min", table: "BreakReminder")
            case .hours(let h):
                return String(localized: "\(h) hr", table: "BreakReminder")
            }
        }

        var timeInterval: TimeInterval {
            switch self {
            case .minutes(let m):
                return TimeInterval(m * 60)
            case .hours(let h):
                return TimeInterval(h * 3600)
            }
        }
    }

    /// Common interval options
    static let commonIntervals: [IntervalOption] = [
        .minutes(10),
        .minutes(20),
        .minutes(30),
        .hours(1),
        .hours(2),
    ]
}

// MARK: - UNUserNotificationCenterDelegate

extension BreakReminderManager: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Capture the action identifier
        let actionIdentifier = response.actionIdentifier
        Task { @MainActor in
            // Handle notification response
            if actionIdentifier == UNNotificationDefaultActionIdentifier {
                // User tapped notification - snooze for 5 minutes
                self.snooze(minutes: 5)
            }
        }
        completionHandler()
    }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
}
