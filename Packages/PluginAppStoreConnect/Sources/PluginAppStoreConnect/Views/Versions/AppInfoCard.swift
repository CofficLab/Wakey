import SwiftUI

struct AppInfoCard: View {
    let app: AppInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 应用名称和图标
            HStack {
                Image(systemName: "app.badge")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                Text(app.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            Divider()

            // 基本信息
            InfoRow(label: "Bundle ID", value: app.bundleId, systemImage: "doc.text")
            InfoRow(label: "SKU", value: app.sku, systemImage: "barcode")
            InfoRow(label: "应用 ID", value: app.id, systemImage: "number")

            if let locale = app.primaryLocale {
                InfoRow(label: "主要语言", value: formatLocale(locale), systemImage: "globe")
            }

            // 儿童应用标记
            if let isKidsApp = app.isOrEverWasMadeForKids {
                HStack {
                    Image(systemName: isKidsApp ? "heart.fill" : "heart.slash")
                        .foregroundColor(isKidsApp ? .pink : .secondary)
                    Text(isKidsApp ? "儿童应用" : "非儿童应用")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // App Store 状态
            if !app.appStoreStates.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal")
                        .foregroundColor(.green)
                    ForEach(app.appStoreStates, id: \.self) { state in
                        Text(formatAppState(state))
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
            }

            // 订阅状态 URL
            if let url = app.subscriptionStatusUrl {
                InfoRow(label: "订阅状态", value: url, systemImage: "link")
            }
        }
        .padding(12)
        .background(.regularMaterial)
        .cornerRadius(8)
    }

    private func formatLocale(_ locale: String) -> String {
        let localeMap: [String: String] = [
            "zh-Hans": "简体中文",
            "zh-Hant": "繁体中文",
            "en-US": "英语（美国）",
            "en-GB": "英语（英国）",
            "ja": "日语",
            "ko": "韩语"
        ]
        return localeMap[locale] ?? locale
    }

    private func formatAppState(_ state: String) -> String {
        switch state {
        case "READY_FOR_SALE": return "可售"
        case "DEVELOPER_REMOVED_FROM_SALE": return "开发者下架"
        case "REJECTED": return "被拒绝"
        default: return state
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

#Preview("App Info Card") {
    AppInfoCard(app: AppInfo(
        id: "123456",
        name: "Wakey",
        bundleId: "com.cofficlab.Wakey",
        sku: "WAKEY001",
        appStoreStates: ["READY_FOR_SALE"],
        primaryLocale: "zh-Hans",
        isOrEverWasMadeForKids: false,
        subscriptionStatusUrl: nil
    ))
    .padding()
    .frame(width: 400)
}
