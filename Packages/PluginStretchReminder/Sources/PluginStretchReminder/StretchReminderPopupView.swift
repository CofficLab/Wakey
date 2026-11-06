import SwiftUI

struct StretchReminderPopupView: View {
    @State private var manager = StretchReminderManager.shared
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "figure.stand")
                    .font(.system(size: 11))
                    .foregroundColor(.orange)
                Text("Stretch", tableName: "StretchReminder", bundle: .module)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
                StretchReminderControls()
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 4)

            VStack(alignment: .leading, spacing: 4) {
                Text("Status", tableName: "StretchReminder", bundle: .module)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)
                StretchReminderStatusInfo()
            }
            Divider().padding(.horizontal, 12).padding(.vertical, 4)
            VStack(alignment: .leading, spacing: 4) {
                Text("Interval", tableName: "StretchReminder", bundle: .module)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)
                StretchIntervalPicker()
            }
        }
        .padding(.bottom, 8)
        .background(
            ZStack {
                LinearGradient(colors: [Color.orange.opacity(0.05), Color.red.opacity(0.03), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                ZStack {
                    Image(systemName: "figure.stand")
                        .font(.system(size: 80))
                        .foregroundColor(.orange.opacity(0.04))
                        .rotationEffect(.degrees(-15))
                        .offset(x: 100, y: 40)
                }
            }
        )
        .clipped()
    }
}
