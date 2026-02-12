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

    /// Activate anti-sleep
    /// - Parameter duration: Duration (seconds), 0 for indefinite
    func activate(duration: TimeInterval = 0) {
        activate(mode: .systemAndDisplay, duration: duration)
    }

    /// Activate anti-sleep and turn off display immediately
    func activateAndTurnOffDisplay(duration: TimeInterval = 0) {
        // 1. Activate anti-sleep (system only, allowing display sleep)
        activate(mode: .systemOnly, duration: duration)

        // 2. Update state
        self.activeAction = .systemOnly
        self.selectedDuration = duration

        // 3. Turn off display
        turnOffDisplay()
    }

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

    func activate(mode: SleepMode, duration: TimeInterval = 0) {
        guard !isActive else {
            if Self.verbose {
                os_log("\(self.t)Anti-sleep already active, ignoring duplicate request")
            }
            return
        }

        self.mode = mode
        let reason = "Anti-sleep mode enabled via Wakey" as NSString

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

    /// Deactivate anti-sleep
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

            // Stop timer
            timer?.invalidate()
            timer = nil

            if Self.verbose {
                os_log("\(self.t)Caffeinate deactivated successfully")
            }

            // Notify system to restore status bar appearance
            NotificationCenter.postRequestStatusBarAppearanceUpdate(isActive: false, source: "CaffeinatePlugin")
        } else {
            if systemResult != kIOReturnSuccess {
                os_log(.error, "\(self.t)Failed to release system sleep assertion: \(systemResult)")
            }
            if displayResult != kIOReturnSuccess {
                os_log(.error, "\(self.t)Failed to release display sleep assertion: \(displayResult)")
            }
        }
    }

    /// Toggle anti-sleep state
    func toggle() {
        if isActive {
            deactivate()
        } else {
            activate(mode: mode)
        }
    }

    /// Get the duration since activation
    /// - Returns: Time interval since activation (seconds), or nil if not active
    func getActiveDuration() -> TimeInterval? {
        guard let start = startTime else { return nil }
        return Date().timeIntervalSince(start)
    }

    // MARK: - Private Methods

    /// Start timer
    /// - Parameter duration: Duration (seconds)
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
    enum SleepMode: String, CaseIterable {
        case systemOnly
        case systemAndDisplay
        
        var displayName: String {
            switch self {
            case .systemOnly:
                return "Keep system awake, allow display sleep"
            case .systemAndDisplay:
                return "Keep system awake, prevent display sleep"
            }
        }
    }

    /// Preset duration options
    enum DurationOption: Hashable, Equatable {
        case indefinite
        case minutes(Int)
        case hours(Int)

        var displayName: String {
            switch self {
            case .indefinite:
                return "Indefinite"
            case let .minutes(m):
                return "\(m) minutes"
            case let .hours(h):
                return "\(h) hours"
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
