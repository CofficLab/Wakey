import SwiftUI

public struct WakeryMotionPreference: Equatable, Sendable {
    public var reduceMotion: Bool
    public var disableAnimations: Bool
    public var disableListAnimations: Bool

    public init(
        reduceMotion: Bool = false,
        disableAnimations: Bool = false,
        disableListAnimations: Bool = false
    ) {
        self.reduceMotion = reduceMotion
        self.disableAnimations = disableAnimations
        self.disableListAnimations = disableListAnimations
    }

    public var allowsMotion: Bool {
        !reduceMotion && !disableAnimations
    }

    public var allowsListMotion: Bool {
        allowsMotion && !disableListAnimations
    }
}

private struct WakeryMotionPreferenceKey: EnvironmentKey {
    static let defaultValue = WakeryMotionPreference()
}

public extension EnvironmentValues {
    var wakeryMotionPreference: WakeryMotionPreference {
        get { self[WakeryMotionPreferenceKey.self] }
        set { self[WakeryMotionPreferenceKey.self] = newValue }
    }
}

@propertyWrapper
public struct WakeryMotionPreferenceReader: DynamicProperty {
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.wakeryMotionPreference) private var preference

    public init() {}

    public var wrappedValue: WakeryMotionPreference {
        WakeryMotionPreference(
            reduceMotion: systemReduceMotion || preference.reduceMotion,
            disableAnimations: preference.disableAnimations,
            disableListAnimations: preference.disableListAnimations
        )
    }
}

public extension View {
    func wakeryMotionPreference(_ preference: WakeryMotionPreference) -> some View {
        environment(\.wakeryMotionPreference, preference)
    }

    func wakeryDisableAnimations(_ disabled: Bool = true) -> some View {
        transformEnvironment(\.wakeryMotionPreference) { preference in
            preference.disableAnimations = disabled
        }
    }

    func wakeryDisableListAnimations(_ disabled: Bool = true) -> some View {
        transformEnvironment(\.wakeryMotionPreference) { preference in
            preference.disableListAnimations = disabled
        }
    }
}
