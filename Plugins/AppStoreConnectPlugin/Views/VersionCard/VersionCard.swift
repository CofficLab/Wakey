import SwiftUI

struct VersionCard: View {
    let version: AppStoreVersion

    @StateObject private var service = AppStoreConnectService.shared

    @State private var isLoadingDetail = false
    @State private var isEditing = false
    @State private var newVersionString = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    @State private var editingMarketingUrl = false
    @State private var editingSupportUrl = false
    @State private var tempMarketingUrl = ""
    @State private var tempSupportUrl = ""
    @State private var isSavingUrl = false

    private var reviewDetail: AppStoreReviewDetail? {
        service.versionReviewDetails[version.id]
    }

    private var shouldShowLoading: Bool {
        isLoadingDetail
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if shouldShowLoading {
                VersionCardLoadingView(version: version)
            } else {
                VersionCardHeaderView(
                    version: version,
                    isEditing: $isEditing,
                    newVersionString: $newVersionString,
                    isSaving: $isSaving,
                    errorMessage: $errorMessage,
                    isLoadingDetail: $isLoadingDetail,
                    onSave: { Task { await saveVersion() } },
                    onCancel: cancelEditing,
                    onRefresh: {
                        guard !isLoadingDetail, !isSaving else { return }
                        Task {
                            isLoadingDetail = true
                            await refreshDetail()
                            isLoadingDetail = false
                        }
                    }
                )

                Divider()

                VersionCardInfoView(version: version)

                if let localization = version.localization {
                    Divider()
                    VersionCardLocalizationView(
                        localization: localization,
                        editingMarketingUrl: $editingMarketingUrl,
                        editingSupportUrl: $editingSupportUrl,
                        tempMarketingUrl: $tempMarketingUrl,
                        tempSupportUrl: $tempSupportUrl,
                        isSavingUrl: $isSavingUrl,
                        onSaveMarketingUrl: { url in Task { await saveMarketingUrl(url: url) } },
                        onSaveSupportUrl: { url in Task { await saveSupportUrl(url: url) } }
                    )
                }

                if let review = reviewDetail {
                    Divider()
                    VersionCardReviewView(review: review)
                }

                Text("ID: \(version.id)")
                    .font(.caption2)
                    .foregroundColor(Color.secondary.opacity(0.6))
                    .textSelection(.enabled)
            }
        }
        .padding(12)
        .background(.regularMaterial)
        .cornerRadius(8)
        .task {
            if version.localization == nil && service.versionReviewDetails[version.id] == nil {
                isLoadingDetail = true
                await service.fetchVersionDetail(versionId: version.id)
                isLoadingDetail = false
            }
        }
    }

    private func refreshDetail() async {
        await service.fetchVersionDetail(versionId: version.id)
    }

    private func startEditing() {
        newVersionString = version.versionString
        isEditing = true
        errorMessage = nil
    }

    private func cancelEditing() {
        isEditing = false
        newVersionString = ""
        errorMessage = nil
    }

    private func saveVersion() async {
        guard !newVersionString.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "版本号不能为空"
            return
        }

        guard newVersionString != version.versionString else {
            cancelEditing()
            return
        }

        isSaving = true
        errorMessage = nil

        do {
            try await service.updateVersion(versionId: version.id, newVersionString: newVersionString)
            isEditing = false
        } catch {
            errorMessage = (error as? AppStoreConnectError)?.localizedDescription ?? error.localizedDescription
        }

        isSaving = false
    }

    private func saveMarketingUrl(url: String) async {
        guard let localizationId = version.localization?.id else { return }
        isSavingUrl = true
        do {
            try await service.updateVersionLocalization(
                localizationId: localizationId,
                versionId: version.id,
                marketingUrl: url
            )
            editingMarketingUrl = false
        } catch {
            print("保存营销网址失败: \(error.localizedDescription)")
        }
        isSavingUrl = false
    }

    private func saveSupportUrl(url: String) async {
        guard let localizationId = version.localization?.id else { return }
        isSavingUrl = true
        do {
            try await service.updateVersionLocalization(
                localizationId: localizationId,
                versionId: version.id,
                supportUrl: url
            )
            editingSupportUrl = false
        } catch {
            print("保存技术支持网址失败: \(error.localizedDescription)")
        }
        isSavingUrl = false
    }
}

#Preview("App Store Connect - Version Card") {
    AppStoreConnectVersionsView()
        .inRootView()
        .withDebugBar()
}
