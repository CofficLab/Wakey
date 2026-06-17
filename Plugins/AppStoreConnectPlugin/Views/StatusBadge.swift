import SwiftUI

/// 状态徽章组件
struct StatusBadge: View {
    let state: String

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)

            Text(displayName)
                .font(.caption)
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .cornerRadius(12)
    }

    private var color: Color {
        switch state.lowercased() {
        case "ready_for_sale", "ready for sale":
            return .green
        case "waiting_for_review", "waiting for review":
            return .orange
        case "in_review", "in review":
            return .blue
        case "developer_rejected", "developer rejected":
            return .red
        case "rejected":
            return .red
        case "prepare_for_submission", "prepare for submission":
            return .yellow
        case "pending_developer_release", "pending developer release":
            return .purple
        case "processing", "develop", "development":
            return .gray
        default:
            return .gray
        }
    }

    private var displayName: String {
        state.replacingOccurrences(of: "_", with: " ").capitalized
    }
}

// MARK: - Preview

#Preview("Status Badge") {
    VStack(alignment: .leading, spacing: 8) {
        StatusBadge(state: "READY_FOR_SALE")
        StatusBadge(state: "WAITING_FOR_REVIEW")
        StatusBadge(state: "IN_REVIEW")
        StatusBadge(state: "DEVELOPER_REJECTED")
        StatusBadge(state: "PREPARE_FOR_SUBMISSION")
        StatusBadge(state: "PROCESSING")
    }
    .padding()
}
