import Foundation
import MagicKit
import Observation
import OSLog
import UserNotifications
import SwiftUI

/// Hydration Reminder Manager: manages hydration break reminders
@MainActor
@Observable
class HydrationReminderManager: NSObject, SuperLog {
    nonisolated static let emoji = "💧"
    nonisolated static let verbose: Bool = true

    static let shared = HydrationReminderManager()
    
    private let userDefaultsKey = "HydrationReminderInterval"

    private(set) var isActive: Bool = false
    private(set) var selectedInterval: TimeInterval = 2 * 60 * 60 // Default 2 hours
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
    private var currentOverlayWindow: HydrationReminderOverlayWindow?

    private override init() {
        super.init()
        
        // Load persisted interval
        let savedInterval = UserDefaults.standard.double(forKey: userDefaultsKey)
        if savedInterval > 0 {
            self.selectedInterval = savedInterval
        }

        if Self.verbose {
            os_log("\(self.t)HydrationReminderManager initialized")
        }
        checkNotificationPermission()
    }

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

    func openNotificationSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
            NSWorkspace.shared.open(url)
        }
    }

    func start() {
        guard !isActive else { return }
        self.isActive = true
        self.startTime = Date()
        scheduleNextBreak()
        NotificationCenter.postRequestBreakReminderStatusUpdate(isActive: true, type: "hydration")
    }

    func stop() {
        guard isActive else { return }
        timer?.invalidate()
        timer = nil
        isActive = false
        nextBreakTime = nil
        startTime = nil
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        NotificationCenter.postRequestBreakReminderStatusUpdate(isActive: false, type: nil)
    }

    func snooze(minutes: Int) {
        guard isActive else { return }
        let interval = TimeInterval(minutes * 60)
        scheduleBreak(in: interval)
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
        currentOverlayWindow = HydrationReminderOverlayWindow()
        currentOverlayWindow?.showAndFadeOut()
    }

    private func scheduleNotification(in interval: TimeInterval) {
        guard notificationPermissionGranted else { return }
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Time for a Break!", table: "HydrationReminder")
        content.body = String(localized: "Don't forget to drink some water!", table: "HydrationReminder")
        content.sound = .default
        content.categoryIdentifier = "HYDRATION_REMINDER"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { [weak self] granted, _ in
            Task { @MainActor in
                self?.notificationPermissionGranted = granted
                self?.permissionStatus = granted ? .authorized : .denied
            }
        }
        center.delegate = self
    }

    func cleanup() {
        timer?.invalidate()
        timer = nil
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

extension HydrationReminderManager {
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
            case .minutes(let m): return "\(m) min"
            case .hours(let h): return "\(h) hr"
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
        .minutes(30),
        .hours(1),
        .hours(2),
        .hours(3),
    ]
}

extension HydrationReminderManager: UNUserNotificationCenterDelegate {
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
