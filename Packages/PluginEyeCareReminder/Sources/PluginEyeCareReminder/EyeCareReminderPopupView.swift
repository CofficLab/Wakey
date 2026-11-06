import SwiftUI

/// Status bar popup view for the Eye Care Reminder plugin
struct EyeCareReminderPopupView: View {
    @State private var manager = EyeCareReminderManager.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header with plugin name
            HStack {
                Image(systemName: "eye.fill")
                    .font(.system(size: 11))
                    .foregroundColor(.green)

                Text("Eye Care", tableName: "EyeCareReminder", bundle: .module)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()
                
                EyeCareReminderControls()
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 4)

            // Status info
            VStack(alignment: .leading, spacing: 4) {
                Text("Status", tableName: "EyeCareReminder", bundle: .module)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)

                EyeCareReminderStatusInfo()
            }

            Divider()
                .padding(.horizontal, 12)
                .padding(.vertical, 4)

            // Interval picker
            VStack(alignment: .leading, spacing: 4) {
                Text("Interval", tableName: "EyeCareReminder", bundle: .module)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 4)

                EyeCareIntervalPicker()
            }

        }
        .padding(.bottom, 8)
        .background(
            ZStack {
                LinearGradient(
                    colors: [
                        Color.green.opacity(0.05),
                        Color.blue.opacity(0.03),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                ZStack {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green.opacity(0.04))
                        .rotationEffect(.degrees(-15))
                        .offset(x: 100, y: 40)
                }
            }
        )
        .clipped()
    }
}

