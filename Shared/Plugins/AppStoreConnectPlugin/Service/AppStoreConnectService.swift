import CryptoKit
import Foundation
import SwiftUI
internal import Combine

/// App Store Connect 服务
@MainActor
class AppStoreConnectService: ObservableObject {
    static let shared = AppStoreConnectService()

    @Published var apiKey: String {
        didSet { UserDefaults.standard.set(apiKey, forKey: "appstore_api_key") }
    }

    @Published var issuerId: String {
        didSet { UserDefaults.standard.set(issuerId, forKey: "appstore_issuer_id") }
    }

    @Published var bundleId: String {
        didSet { UserDefaults.standard.set(bundleId, forKey: "appstore_bundle_id") }
    }

    @Published var keyId: String {
        didSet { UserDefaults.standard.set(keyId, forKey: "appstore_key_id") }
    }

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var versions: [AppStoreVersion] = []
    @Published var versionReviewDetails: [String: AppStoreReviewDetail] = [:]
    @Published var currentApp: AppInfo?

    // 应用列表相关
    @Published var apps: [AppInfo] = []
    @Published var isLoadingApps = false
    @Published var appsError: String?

    private init() {
        self.apiKey = UserDefaults.standard.string(forKey: "appstore_api_key") ?? ""
        self.issuerId = UserDefaults.standard.string(forKey: "appstore_issuer_id") ?? ""
        self.bundleId = UserDefaults.standard.string(forKey: "appstore_bundle_id") ?? "com.cofficlab.Wakey"
        self.keyId = UserDefaults.standard.string(forKey: "appstore_key_id") ?? ""
    }

    var isConfigured: Bool {
        !apiKey.isEmpty && !issuerId.isEmpty && !bundleId.isEmpty && !keyId.isEmpty
    }

    private func getKeyId() -> String? {
        !keyId.isEmpty ? keyId : nil
    }

    // MARK: - API 请求

    func fetchVersions() async {
        guard isConfigured else {
            errorMessage = "请先配置 API 密钥"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            print("=== App Store Connect API 请求开始 ===")
            print("配置状态:")
            print("  Bundle ID: \(bundleId)")
            print("  Issuer ID: \(issuerId)")
            print("  API Key 长度: \(apiKey.count) 字符")

            // 生成 JWT
            let jwt = try generateJWT()

            // 第一步：通过 Bundle ID 获取应用 ID
            let appsRequest = FetchAppsAPI.Request(bundleId: bundleId)
            print("\n第一步请求: 获取应用 ID")

            let appsResponse = try await FetchAppsAPI.execute(request: appsRequest, jwt: jwt)
            print("  成功！返回 \(appsResponse.data.count) 个应用")

            guard let app = appsResponse.data.first else {
                errorMessage = AppStoreConnectError.appNotFound(bundleId).localizedDescription
                isLoading = false
                return
            }

            print("  应用 ID: \(app.id)")
            print("  应用名称: \(app.attributes?.name ?? "未知")")

            // 第二步：使用应用 ID 获取版本列表（不包含详情）
            let versionsRequest = FetchAppVersionsAPI.Request(appId: app.id)
            print("\n第二步请求: 获取版本列表")
            print("  URL: \(versionsRequest.url?.absoluteString ?? "无效")")

            let versionsResponse = try await FetchAppVersionsAPI.execute(request: versionsRequest, jwt: jwt)
            print("  成功！返回 \(versionsResponse.data.count) 个版本")

            // 更新应用信息
            if let appData = app.attributes {
                currentApp = AppInfo(
                    id: app.id,
                    name: appData.name ?? "未知",
                    bundleId: appData.bundleId ?? "",
                    sku: appData.sku ?? "",
                    appStoreStates: appData.appStoreStates ?? [],
                    primaryLocale: appData.primaryLocale,
                    isOrEverWasMadeForKids: appData.isOrEverWasMadeForKids,
                    subscriptionStatusUrl: appData.subscriptionStatusUrl
                )
            }

            // 转换为业务模型（不包含详细信息）
            versions = versionsResponse.data.map { item in
                AppStoreVersion(
                    id: item.id,
                    platform: item.attributes.platform,
                    versionString: item.attributes.versionString,
                    appStoreState: item.attributes.appStoreState,
                    appVersionState: item.attributes.appVersionState,
                    createdDate: VersionFormatters.formatDate(item.attributes.createdDate),
                    releaseType: item.attributes.releaseType ?? "MANUAL",
                    downloadable: item.attributes.downloadable,
                    copyright: item.attributes.copyright,
                    usesIdfa: item.attributes.usesIdfa,
                    localization: nil // 详情按需加载
                )
            }

            print("\n=== API 请求成功完成 ===")
            print("提示：版本详情将在选中版本时按需加载")

        } catch {
            let errorDesc = (error as? AppStoreConnectError)?.localizedDescription ?? error.localizedDescription
            print("\n=== API 请求失败 ===")
            print("错误类型: \(type(of: error))")
            print("错误描述: \(errorDesc)")
            print("完整错误: \(error)")

            self.errorMessage = errorDesc
        }

        isLoading = false
    }

    /// 修改版本号
    func updateVersion(versionId: String, newVersionString: String) async throws {
        guard isConfigured else {
            throw AppStoreConnectError.jwtGenerationFailed("请先配置 API 密钥")
        }

        print("=== 修改版本号开始 ===")
        print("  版本 ID: \(versionId)")
        print("  新版本号: \(newVersionString)")

        let jwt = try generateJWT()
        let request = UpdateAppVersionAPI.Request(
            versionId: versionId,
            versionString: newVersionString,
            copyright: nil,
            releaseType: nil,
            earliestReleaseDate: nil,
            downloadable: nil
        )

        let response = try await UpdateAppVersionAPI.execute(request: request, jwt: jwt)
        print("  成功！")

        // 更新本地版本数据
        if let index = versions.firstIndex(where: { $0.id == versionId }) {
            let version = versions[index]
            let updatedVersion = AppStoreVersion(
                id: version.id,
                platform: version.platform,
                versionString: newVersionString,
                appStoreState: version.appStoreState,
                appVersionState: version.appVersionState,
                createdDate: version.createdDate,
                releaseType: version.releaseType,
                downloadable: version.downloadable,
                copyright: version.copyright,
                usesIdfa: version.usesIdfa,
                localization: version.localization
            )
            versions[index] = updatedVersion
            print("=== 版本号修改成功 ===")
        }
    }

    /// 修改版本本地化信息
    func updateVersionLocalization(
        localizationId: String,
        versionId: String,
        marketingUrl: String? = nil,
        supportUrl: String? = nil,
        description: String? = nil,
        keywords: String? = nil,
        promotionalText: String? = nil,
        whatsNew: String? = nil
    ) async throws {
        guard isConfigured else {
            throw AppStoreConnectError.jwtGenerationFailed("请先配置 API 密钥")
        }

        print("=== 修改版本本地化信息开始 ===")
        print("  本地化 ID: \(localizationId)")

        let jwt = try generateJWT()
        let request = UpdateAppVersionLocalizationAPI.Request(
            localizationId: localizationId,
            description: description,
            keywords: keywords,
            marketingUrl: marketingUrl,
            promotionalText: promotionalText,
            supportUrl: supportUrl,
            whatsNew: whatsNew
        )

        let response = try await UpdateAppVersionLocalizationAPI.execute(request: request, jwt: jwt)
        print("  成功！")

        // 更新本地版本数据
        if let index = versions.firstIndex(where: { $0.id == versionId }) {
            let version = versions[index]
            let updatedLocalization = AppStoreVersionLocalization(
                id: localizationId,
                locale: version.localization?.locale,
                description: response.data.attributes.description ?? version.localization?.description,
                whatsNew: response.data.attributes.whatsNew ?? version.localization?.whatsNew,
                promotionalText: response.data.attributes.promotionalText ?? version.localization?.promotionalText,
                keywords: response.data.attributes.keywords ?? version.localization?.keywords,
                marketingUrl: response.data.attributes.marketingUrl ?? version.localization?.marketingUrl,
                supportUrl: response.data.attributes.supportUrl ?? version.localization?.supportUrl
            )

            let updatedVersion = AppStoreVersion(
                id: version.id,
                platform: version.platform,
                versionString: version.versionString,
                appStoreState: version.appStoreState,
                appVersionState: version.appVersionState,
                createdDate: version.createdDate,
                releaseType: version.releaseType,
                downloadable: version.downloadable,
                copyright: version.copyright,
                usesIdfa: version.usesIdfa,
                localization: updatedLocalization
            )
            versions[index] = updatedVersion
            print("=== 版本本地化信息修改成功 ===")
        }
    }

    /// 获取单个版本的详细信息
    func fetchVersionDetail(versionId: String) async {
        guard isConfigured else {
            errorMessage = "请先配置 API 密钥"
            return
        }

        do {
            print("=== 获取版本详情开始 ===")
            print("  版本 ID: \(versionId)")

            let jwt = try generateJWT()
            let request = FetchVersionDetailAPI.Request(versionId: versionId)
            print("  URL: \(request.url?.absoluteString ?? "无效")")

            let response = try await FetchVersionDetailAPI.execute(request: request, jwt: jwt)
            print("  成功！")

            // 处理 included 资源
            var reviewDetail: AppStoreReviewDetail?
            var localization: AppStoreVersionLocalization?

            if let included = response.included {
                for resource in included {
                    switch resource {
                    case let .appStoreReviewDetail(reviewData):
                        print("  [详情] 审核详情 - ID: \(reviewData.id)")
                        reviewDetail = AppStoreReviewDetail(
                            contactFirstName: reviewData.attributes.contactFirstName,
                            contactLastName: reviewData.attributes.contactLastName,
                            contactPhone: reviewData.attributes.contactPhone,
                            contactEmail: reviewData.attributes.contactEmail,
                            demoAccountRequired: reviewData.attributes.demoAccountRequired,
                            demoAccountName: reviewData.attributes.demoAccountName,
                            demoAccountPassword: reviewData.attributes.demoAccountPassword,
                            notes: reviewData.attributes.notes
                        )

                    case let .appStoreVersionLocalization(localizationData):
                        print("  [详情] 本地化 - ID: \(localizationData.id), locale: \(localizationData.attributes.locale ?? "nil")")
                        localization = AppStoreVersionLocalization(
                            id: localizationData.id,
                            locale: localizationData.attributes.locale,
                            description: localizationData.attributes.description,
                            whatsNew: localizationData.attributes.whatsNew,
                            promotionalText: localizationData.attributes.promotionalText,
                            keywords: localizationData.attributes.keywords,
                            marketingUrl: localizationData.attributes.marketingUrl,
                            supportUrl: localizationData.attributes.supportUrl
                        )

                    default:
                        break
                    }
                }
            }

            // 更新版本数据
            if let index = versions.firstIndex(where: { $0.id == versionId }) {
                let version = versions[index]
                let updatedVersion = AppStoreVersion(
                    id: version.id,
                    platform: version.platform,
                    versionString: version.versionString,
                    appStoreState: version.appStoreState,
                    appVersionState: version.appVersionState,
                    createdDate: version.createdDate,
                    releaseType: version.releaseType,
                    downloadable: version.downloadable,
                    copyright: version.copyright,
                    usesIdfa: version.usesIdfa,
                    localization: localization
                )
                versions[index] = updatedVersion

                // 存储审核详情
                if let reviewDetail = reviewDetail {
                    versionReviewDetails[versionId] = reviewDetail
                }

                print("=== 版本详情获取成功 ===")
            }

        } catch {
            let errorDesc = (error as? AppStoreConnectError)?.localizedDescription ?? error.localizedDescription
            print("=== 版本详情获取失败 ===")
            print("错误描述: \(errorDesc)")
            errorMessage = errorDesc
        }
    }

    /// 获取所有应用列表
    func fetchAllApps() async {
        guard isConfigured else {
            appsError = "请先配置 API 密钥"
            return
        }

        isLoadingApps = true
        appsError = nil

        do {
            print("=== 获取应用列表开始 ===")

            // 生成 JWT
            let jwt = try generateJWT()

            // 获取所有应用
            let appsRequest = FetchAllAppsAPI.Request()
            print("请求 URL: \(appsRequest.url?.absoluteString ?? "无效")")

            let appsResponse = try await FetchAllAppsAPI.execute(request: appsRequest, jwt: jwt)
            print("成功！返回 \(appsResponse.data.count) 个应用")

            // 转换为业务模型
            apps = appsResponse.data.map { app in
                AppInfo(
                    id: app.id,
                    name: app.attributes?.name ?? "未知",
                    bundleId: app.attributes?.bundleId ?? "",
                    sku: app.attributes?.sku ?? "",
                    appStoreStates: app.attributes?.appStoreStates ?? [],
                    primaryLocale: app.attributes?.primaryLocale,
                    isOrEverWasMadeForKids: app.attributes?.isOrEverWasMadeForKids,
                    subscriptionStatusUrl: app.attributes?.subscriptionStatusUrl
                )
            }

            print("应用列表:")
            for app in apps {
                print("  - \(app.name) (\(app.bundleId))")
            }

            print("\n=== 获取应用列表成功 ===")

        } catch {
            let errorDesc = (error as? AppStoreConnectError)?.localizedDescription ?? error.localizedDescription
            print("\n=== 获取应用列表失败 ===")
            print("错误描述: \(errorDesc)")

            self.appsError = errorDesc
        }

        isLoadingApps = false
    }

    // MARK: - JWT 辅助函数

    /// 解码 JWT 的 payload 部分
    private func decodeJWTPayload(_ jwt: String) -> Data? {
        let parts = jwt.split(separator: ".")
        guard parts.count == 3 else { return nil }
        let payload = String(parts[1])
        return Data(base64Encoded: payload.replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/"))
    }
}
