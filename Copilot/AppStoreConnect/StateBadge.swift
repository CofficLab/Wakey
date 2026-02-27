import SwiftUI

struct StateBadge: View {
    let state: String

    var body: some View {
        Text(formatState(state))
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(badgeColor(for: state))
            .foregroundColor(.white)
            .cornerRadius(4)
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

    private func formatState(_ state: String) -> String {
        switch state {
        case "READY_FOR_SALE": return "可销售"
        case "PROCESSING_TO_GO_ON_SALE": return "处理中"
        case "IN_REVIEW": return "审核中"
        case "PENDING_DEVELOPER_RELEASE": return "等待发布"
        case "REJECTED": return "已拒绝"
        case "DEVELOPER_REJECTED": return "开发者拒绝"
        case "METADATA_REJECTED": return "元数据拒绝"
        case "REMOVED_FROM_SALE": return "已下架"
        default: return state
        }
    }
}
