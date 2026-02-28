import SwiftUI

struct VersionCard: View {
    let version: AppStoreVersion

    @StateObject private var service = AppStoreConnectService.shared

    @State private var isLoadingDetail = false
    @State private var isEditing = false
    @State private var newVersionString = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    // 网址编辑状态
    @State private var editingMarketingUrl = false
    @State private var editingSupportUrl = false
    @State private var tempMarketingUrl = ""
    @State private var tempSupportUrl = ""
    @State private var isSavingUrl = false

    // 从 Service 获取审核详情
    private var reviewDetail: AppStoreReviewDetail? {
        service.versionReviewDetails[version.id]
    }

    // 是否需要显示加载状态
    private var shouldShowLoading: Bool {
        isLoadingDetail && version.localization == nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if shouldShowLoading {
                ProgressView("加载版本详情...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
            } else {
            // 版本号和状态
            HStack {
                HStack {
                if isEditing {
                    // 编辑模式
                    HStack(spacing: 8) {
                        Text("v")
                            .foregroundColor(.secondary)
                        TextField("版本号", text: $newVersionString)
                            .textFieldStyle(.roundedBorder)
                            .font(.headline)
                            .frame(width: 120)
                            .onSubmit {
                                Task { await saveVersion() }
                            }

                        if isSaving {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Button("保存") {
                                Task { await saveVersion() }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.small)

                            Button("取消") {
                                cancelEditing()
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                    }
                } else {
                    // 查看模式
                    Button(action: {
                        startEditing()
                    }) {
                        HStack(spacing: 6) {
                            Text("v\(version.versionString)")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Image(systemName: "pencil.circle")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .help("点击编辑版本号")

                    Spacer()
                    StateBadge(state: version.appStoreState)
                }

                // 错误提示
                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                }

                Spacer()

                // 刷新按钮
                Button(action: {
                    Task {
                        isLoadingDetail = true
                        await service.fetchVersionDetail(versionId: version.id)
                        isLoadingDetail = false
                    }
                }) {
                    Image(systemName: isLoadingDetail ? "arrow.clockwise" : "arrow.clockwise")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("刷新版本详情")
                .disabled(isLoadingDetail)
            }

            Divider()

            // 平台信息
            HStack {
                Image(systemName: platformIcon)
                    .foregroundColor(.accentColor)
                Text(VersionFormatters.formatPlatform(version.platform))
                    .font(.subheadline)
                Spacer()
            }

            // 日期信息
            Label("创建: \(version.createdDate)", systemImage: "calendar.badge.plus")
                .font(.caption)
                .foregroundColor(.secondary)

            // 发布类型
            if !version.releaseType.isEmpty {
                HStack {
                    Image(systemName: "paperplane")
                    Text("发布: \(VersionFormatters.formatReleaseType(version.releaseType))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // 版权信息
            if let copyright = version.copyright {
                HStack {
                    Image(systemName: "c.circle")
                    Text(copyright)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .textSelection(.enabled)
                }
            }

            // IDFA 使用
            if let usesIdfa = version.usesIdfa {
                HStack {
                    Image(systemName: usesIdfa ? "person.badge.key" : "person.badge")
                    Text(usesIdfa ? "使用 IDFA" : "不使用 IDFA")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // 可下载状态
            if let downloadable = version.downloadable {
                HStack {
                    Label(downloadable ? "可下载" : "不可下载", systemImage: downloadable ? "checkmark.circle" : "xmark.circle")
                        .font(.caption)
                        .foregroundColor(downloadable ? .green : .red)
                }
            }

            // 版本状态
            if let appVersionState = version.appVersionState {
                HStack {
                    Image(systemName: "info.circle")
                    Text("状态: \(formatAppState(appVersionState))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textSelection(.enabled)
                }
            }

            // 版本描述
            if let localization = version.localization {
                Divider()

                // 描述
                if let description = localization.description, !description.isEmpty {
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

                // 更新说明
                if let whatsNew = localization.whatsNew, !whatsNew.isEmpty {
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

                // 推广文本
                if let promotionalText = localization.promotionalText, !promotionalText.isEmpty {
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

                // 语言环境
                if let locale = localization.locale {
                    HStack(spacing: 4) {
                        Image(systemName: "globe")
                            .font(.caption2)
                        Text("语言: \(locale)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                // 关键词
                if let keywords = localization.keywords, !keywords.isEmpty {
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

                // 营销网址
                if let marketingUrl = localization.marketingUrl, !marketingUrl.isEmpty {
                    EditableUrlField(
                        label: "营销网址",
                        icon: "link",
                        url: marketingUrl,
                        isEditing: $editingMarketingUrl,
                        tempUrl: $tempMarketingUrl,
                        isSaving: $isSavingUrl,
                        onSave: { newUrl in
                            Task { await saveMarketingUrl(url: newUrl) }
                        }
                    )
                }

                // 技术支持网址
                if let supportUrl = localization.supportUrl, !supportUrl.isEmpty {
                    EditableUrlField(
                        label: "技术支持",
                        icon: "lifepreserver",
                        url: supportUrl,
                        isEditing: $editingSupportUrl,
                        tempUrl: $tempSupportUrl,
                        isSaving: $isSavingUrl,
                        onSave: { newUrl in
                            Task { await saveSupportUrl(url: newUrl) }
                        }
                    )
                }
            }

            // 审核详情
            if let review = reviewDetail {
                Divider()
                reviewInfoSection(review)
            }

            // 版本 ID
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
            // 如果该版本还没有详情，触发加载
            if version.localization == nil && service.versionReviewDetails[version.id] == nil {
                isLoadingDetail = true
                await service.fetchVersionDetail(versionId: version.id)
                isLoadingDetail = false
            }
        }
    }

    private var platformIcon: String {
        switch version.platform {
        case "IOS": return "iphone"
        case "MAC_OS": return "desktopcomputer"
        case "TV_OS": return "appletv"
        case "VISION_OS": return "visionpro"
        default: return "app.badge"
        }
    }

    private func formatAppState(_ state: String) -> String {
        switch state {
        case "ACCEPTED": return "已接受"
        case "IN_REVIEW": return "审核中"
        case "PREPARED_FOR_SUBMISSION": return "准备提交"
        case "REJECTED": return "被拒绝"
        case "WAITING_FOR_REVIEW": return "等待审核"
        default: return state
        }
    }

    @ViewBuilder
    private func reviewInfoSection(_ review: AppStoreReviewDetail) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("审核信息")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            if let firstName = review.contactFirstName, let lastName = review.contactLastName {
                HStack(spacing: 4) {
                    Image(systemName: "person.circle")
                        .font(.caption2)
                    Text("\(firstName) \(lastName)")
                        .font(.caption2)
                        .textSelection(.enabled)
                }
            }

            if let email = review.contactEmail {
                HStack(spacing: 4) {
                    Image(systemName: "envelope")
                        .font(.caption2)
                    Text(email)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .textSelection(.enabled)
                }
            }

            if let phone = review.contactPhone {
                HStack(spacing: 4) {
                    Image(systemName: "phone")
                        .font(.caption2)
                    Text(phone)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .textSelection(.enabled)
                }
            }

            if let demoRequired = review.demoAccountRequired, demoRequired {
                HStack(spacing: 4) {
                    Image(systemName: "key.fill")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    Text("需要演示账号")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - 编辑功能

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

    // MARK: - 网址编辑

    private func saveMarketingUrl(url: String) async {
        guard let localizationId = version.localization?.id else {
            return
        }

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
        guard let localizationId = version.localization?.id else {
            return
        }

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

// MARK: - Editable URL Field

private struct EditableUrlField: View {
    let label: String
    let icon: String
    let url: String
    @Binding var isEditing: Bool
    @Binding var tempUrl: String
    @Binding var isSaving: Bool
    let onSave: (String) -> Void

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(.secondary)
                .frame(width: 12)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)

            if isEditing {
                // 编辑模式
                TextField("网址", text: $tempUrl)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption2)
                    .onSubmit {
                        onSave(tempUrl)
                    }

                if isSaving {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Button(action: {
                        onSave(tempUrl)
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    .buttonStyle(.plain)
                    .help("保存")

                    Button(action: {
                        isEditing = false
                        tempUrl = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                    .help("取消")
                }
            } else {
                // 查看模式 - 文本框显示
                Text(url)
                    .font(.caption2)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer()

                // 编辑按钮
                Button(action: {
                    tempUrl = url
                    isEditing = true
                }) {
                    Image(systemName: "pencil.circle")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("编辑")

                // 打开链接按钮
                if let linkUrl = URL(string: url) {
                    Link(destination: linkUrl) {
                        Image(systemName: "arrow.up.right.square")
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                    .help("打开链接")
                }
            }
        }
    }
}

#Preview("App Store Connect - Versions") {
    AppStoreConnectVersionsView()
        .inRootView()
        .withDebugBar()
}
