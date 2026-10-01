import SwiftUI

struct VersionCardLocalizationView: View {
    let localization: AppStoreVersionLocalization
    @Binding var editingMarketingUrl: Bool
    @Binding var editingSupportUrl: Bool
    @Binding var tempMarketingUrl: String
    @Binding var tempSupportUrl: String
    @Binding var isSavingUrl: Bool
    let onSaveMarketingUrl: (String) async -> Void
    let onSaveSupportUrl: (String) async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let description = localization.description, !description.isEmpty {
                descriptionSection(description)
            }

            if let whatsNew = localization.whatsNew, !whatsNew.isEmpty {
                whatsNewSection(whatsNew)
            }

            if let promotionalText = localization.promotionalText, !promotionalText.isEmpty {
                promotionalTextSection(promotionalText)
            }

            if let locale = localization.locale {
                localeSection(locale)
            }

            if let keywords = localization.keywords, !keywords.isEmpty {
                keywordsSection(keywords)
            }

            if let marketingUrl = localization.marketingUrl, !marketingUrl.isEmpty {
                marketingUrlSection(marketingUrl)
            }

            if let supportUrl = localization.supportUrl, !supportUrl.isEmpty {
                supportUrlSection(supportUrl)
            }
        }
    }

    @ViewBuilder
    private func descriptionSection(_ description: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("版本描述")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            Text(description)
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(5)
                .multilineTextAlignment(.leading)
                .textSelection(.enabled)
        }
    }

    @ViewBuilder
    private func whatsNewSection(_ whatsNew: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("更新说明")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            Text(whatsNew)
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(5)
                .multilineTextAlignment(.leading)
                .textSelection(.enabled)
        }
    }

    @ViewBuilder
    private func promotionalTextSection(_ promotionalText: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("推广文本")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            Text(promotionalText)
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .textSelection(.enabled)
        }
    }

    @ViewBuilder
    private func localeSection(_ locale: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "globe")
                .font(.caption2)
            Text("语言: \(locale)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    @ViewBuilder
    private func keywordsSection(_ keywords: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("关键词")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            Text(keywords)
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .textSelection(.enabled)
        }
    }

    @ViewBuilder
    private func marketingUrlSection(_ marketingUrl: String) -> some View {
        EditableUrlField(
            label: "营销网址",
            icon: "link",
            url: marketingUrl,
            isEditing: $editingMarketingUrl,
            tempUrl: $tempMarketingUrl,
            isSaving: $isSavingUrl,
            onSave: { url in
                Task {
                    await onSaveMarketingUrl(url)
                }
            }
        )
    }

    @ViewBuilder
    private func supportUrlSection(_ supportUrl: String) -> some View {
        EditableUrlField(
            label: "技术支持",
            icon: "lifepreserver",
            url: supportUrl,
            isEditing: $editingSupportUrl,
            tempUrl: $tempSupportUrl,
            isSaving: $isSavingUrl,
            onSave: { url in
                Task {
                    await onSaveSupportUrl(url)
                }
            }
        )
    }
}
