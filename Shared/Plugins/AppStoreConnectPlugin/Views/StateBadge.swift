import SwiftUI

struct StateBadge: View {
    let state: String

    var body: some View {
        Image(systemName: iconName(for: state))
            .font(.caption)
            .foregroundColor(badgeColor(for: state))
    }

    private func iconName(for state: String) -> String {
        switch state {
        case "READY_FOR_SALE":
            return "checkmark.circle.fill"
        case "PROCESSING_TO_GO_ON_SALE":
            return "arrow.clockwise.circle.fill"
        case "IN_REVIEW":
            return "eye.circle.fill"
        case "PENDING_DEVELOPER_RELEASE":
            return "clock.circle.fill"
        case "REJECTED", "DEVELOPER_REJECTED", "METADATA_REJECTED":
            return "xmark.circle.fill"
        case "REMOVED_FROM_SALE":
            return "minus.circle.fill"
        default:
            return "circle"
        }
    }

    private func badgeColor(for state: String) -> Color {
        switch state {
        case "READY_FOR_SALE":
            return .green
        case "PROCESSING_TO_GO_ON_SALE":
            return .orange
        case "IN_REVIEW", "PENDING_DEVELOPER_RELEASE":
            return .blue
        case "REJECTED", "DEVELOPER_REJECTED", "METADATA_REJECTED":
            return .red
        case "REMOVED_FROM_SALE":
            return .gray
        default:
            return .secondary
        }
    }
}
