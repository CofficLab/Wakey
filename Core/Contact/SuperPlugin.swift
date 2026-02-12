import AppKit
import SwiftUI

/// Plugin Protocol
protocol SuperPlugin: Actor {
    static var id: String { get }
    static var displayName: String { get }
    static var description: String { get }
    static var iconName: String { get }
    static var isConfigurable: Bool { get }
    nonisolated var instanceLabel: String { get }

    @MainActor func addStatusBarPopupView() -> AnyView?
    @MainActor static func providePosterViews() -> [PosterViewConfiguration]
    @MainActor static func provideLogos() -> [LogoConfiguration]

    nonisolated func onRegister()
    nonisolated func onEnable()
    nonisolated func onDisable()
    static var order: Int { get }
}

// MARK: - Default Implementation

extension SuperPlugin {
    static var id: String {
        String(describing: self)
            .replacingOccurrences(of: "Plugin", with: "")
    }

    nonisolated var instanceLabel: String { Self.id }
    static var displayName: String { id }
    static var description: String { "" }
    static var iconName: String { "puzzlepiece" }
    static var isConfigurable: Bool { false }
    static var shouldRegister: Bool { true }

    @MainActor func addStatusBarPopupView() -> AnyView? { nil }
    @MainActor static func providePosterViews() -> [PosterViewConfiguration] { [] }
    @MainActor static func provideLogos() -> [LogoConfiguration] { [] }

    nonisolated func onRegister() {}
    nonisolated func onEnable() {}
    nonisolated func onDisable() {}
    static var order: Int { 999 }
}

// MARK: - Preview

#Preview("App") {
    ContentLayout()
        .inRootView()
        .withDebugBar()
}
