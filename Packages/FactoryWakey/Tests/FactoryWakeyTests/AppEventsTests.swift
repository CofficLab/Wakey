import Foundation
import Testing
@testable import FactoryWakey

@Suite("应用通知事件")
@MainActor
struct AppEventsTests {
    /// 注册一个观察者、发通知、断言收到的 userInfo，然后移除观察者。
    /// `Notification` 在 macOS 上不是 Sendable，因此整个用例限定在 MainActor。
    private func capture(
        name: Notification.Name,
        post: () -> Void
    ) -> [String: Any] {
        var received: [String: Any]?
        let token = NotificationCenter.default.addObserver(
            forName: name,
            object: nil,
            queue: .main
        ) { notification in
            // userInfo 的 key 类型为 AnyHashable，这里收敛为 String
            received = notification.userInfo?.reduce(into: [String: Any]()) { result, pair in
                if let key = pair.key as? String {
                    result[key] = pair.value
                }
            }
        }
        defer { NotificationCenter.default.removeObserver(token) }
        post()
        // 同步投递，.main 队列会在当前 runloop 前处理
        RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        return received ?? [:]
    }

    @Test("生命周期通知名互不相同")
    func lifecycleNamesAreDistinct() {
        let names: [Notification.Name] = [
            .applicationDidFinishLaunching,
            .applicationWillTerminate,
            .applicationDidBecomeActive,
            .applicationDidResignActive,
        ]
        #expect(Set(names).count == 4)
    }

    @Test("状态栏更新通知名与生命周期通知不同")
    func statusBarNamesAreDistinct() {
        #expect(
            Notification.Name.requestStatusBarAppearanceUpdate
                != .applicationDidBecomeActive
        )
        #expect(Notification.Name.requestStatusBarSpeedUpdate != .requestStatusBarAppearanceUpdate)
    }

    @Test("启动通知可被观察者收到")
    func launchNotificationDelivers() {
        var delivered = false
        let token = NotificationCenter.default.addObserver(
            forName: .applicationDidFinishLaunching,
            object: nil,
            queue: .main
        ) { _ in
            delivered = true
        }
        defer { NotificationCenter.default.removeObserver(token) }

        NotificationCenter.postApplicationDidFinishLaunching()
        RunLoop.current.run(until: Date().addingTimeInterval(0.05))

        #expect(delivered)
    }

    @Test("状态栏外观更新通知携带 userInfo")
    func appearanceUpdateCarriesUserInfo() {
        let info = capture(name: .requestStatusBarAppearanceUpdate) {
            NotificationCenter.postRequestStatusBarAppearanceUpdate(isActive: true, source: "probe")
        }
        #expect(info["isActive"] as? Bool == true)
        #expect(info["source"] as? String == "probe")
    }

    @Test("网速更新通知携带数值 userInfo")
    func speedUpdateCarriesNumbers() {
        let info = capture(name: .requestStatusBarSpeedUpdate) {
            NotificationCenter.postRequestStatusBarSpeedUpdate(
                uploadSpeed: 1024,
                downloadSpeed: 2048,
                source: "probe"
            )
        }
        #expect(info["uploadSpeed"] as? Double == 1024)
        #expect(info["downloadSpeed"] as? Double == 2048)
        #expect(info["source"] as? String == "probe")
    }

    @Test("休息提醒更新通知携带 isActive")
    func breakReminderCarriesIsActive() {
        let info = capture(name: .requestBreakReminderStatusUpdate) {
            NotificationCenter.postRequestBreakReminderStatusUpdate(isActive: true, type: "stretch")
        }
        #expect(info["isActive"] as? Bool == true)
        #expect(info["type"] as? String == "stretch")
    }

    @Test("休息提醒更新通知在 type 为 nil 时省略该字段")
    func breakReminderOmitsNilType() {
        let info = capture(name: .requestBreakReminderStatusUpdate) {
            NotificationCenter.postRequestBreakReminderStatusUpdate(isActive: false, type: nil)
        }
        #expect(info["isActive"] as? Bool == false)
        #expect(info["type"] == nil)
}
}
