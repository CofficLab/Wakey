import SwiftUI

// MARK: - 应用网格视图

struct AppsGrid: View {
    let apps: [AppInfo]

    private let columns = [
        GridItem(.adaptive(minimum: 280), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(apps, id: \.id) { app in
                    AppCard(app: app)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - 应用卡片

struct AppCard: View {
    let app: AppInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 应用名称和状态
            HStack {
                Image(systemName: "app.fill")
                    .foregroundColor(.blue)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(app.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Text(app.bundleId)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // 状态指示器
                if !app.appStoreStates.isEmpty {
                    StatusBadge(state: app.appStoreStates.first ?? "")
                }
            }

            Divider()

            // 应用信息
            VStack(alignment: .leading, spacing: 4) {
                AppStoreInfoRow(label: "Bundle ID", value: app.bundleId)
                AppStoreInfoRow(label: "SKU", value: app.sku)
                AppStoreInfoRow(label: "App ID", value: app.id)
            }
            .font(.caption)
        }
        .padding()
        .background(.background)
        .cornerRadius(8)
    }
}

// MARK: - 信息行

struct AppStoreInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
                .font(.caption.monospaced())
        }
    }
}

// MARK: - 空状态视图

struct EmptyAppsView: View {
    let onFetch: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "app.dashed")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("暂无应用")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("获取应用列表") {
                onFetch()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}
