import SwiftUI

public enum WakeryTransition {
    public static func messageInsertion(reduceMotion: Bool) -> AnyTransition {
        reduceMotion
            ? .opacity
            : .asymmetric(
                insertion: .opacity.combined(with: .move(edge: .bottom)),
                removal: .opacity
            )
    }

    public static func disclosureContent(reduceMotion: Bool) -> AnyTransition {
        reduceMotion
            ? .opacity
            : .opacity.combined(with: .move(edge: .top))
    }

    public static func statusPresentation(reduceMotion: Bool) -> AnyTransition {
        reduceMotion
            ? .opacity
            : .asymmetric(
                insertion: .opacity.combined(with: .move(edge: .top)),
                removal: .opacity
            )
    }

    public static func messageInsertion(preference: WakeryMotionPreference) -> AnyTransition {
        messageInsertion(reduceMotion: !preference.allowsListMotion)
    }

    public static func disclosureContent(preference: WakeryMotionPreference) -> AnyTransition {
        disclosureContent(reduceMotion: !preference.allowsMotion)
    }

    public static func statusPresentation(preference: WakeryMotionPreference) -> AnyTransition {
        statusPresentation(reduceMotion: !preference.allowsMotion)
    }
}

public extension View {
    func appMessageInsertionTransition(reduceMotion: Bool) -> some View {
        transition(WakeryTransition.messageInsertion(reduceMotion: reduceMotion))
    }

    func appMessageInsertionTransition(preference: WakeryMotionPreference) -> some View {
        transition(WakeryTransition.messageInsertion(preference: preference))
    }

    func appDisclosureContentTransition(reduceMotion: Bool) -> some View {
        transition(WakeryTransition.disclosureContent(reduceMotion: reduceMotion))
    }

    func appDisclosureContentTransition(preference: WakeryMotionPreference) -> some View {
        transition(WakeryTransition.disclosureContent(preference: preference))
    }

    func appStatusPresentationTransition(reduceMotion: Bool) -> some View {
        transition(WakeryTransition.statusPresentation(reduceMotion: reduceMotion))
    }

    func appStatusPresentationTransition(preference: WakeryMotionPreference) -> some View {
        transition(WakeryTransition.statusPresentation(preference: preference))
    }
}
