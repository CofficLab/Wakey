import Foundation

// MARK: - 版本管理

extension AppStoreConnectService {
    /// 获取应用版本列表
    func fetchVersions() async {
        guard isConfigured else {
            errorMessage = "请先配置 API 密钥"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // 生成 JWT
            let jwt = try generateJWT()

            // 第一步：通过 Bundle ID 获取应用 ID
            let appsRequest = FetchAppsAPI.Request(bundleId: bundleId)

            let appsResponse = try await FetchAppsAPI.execute(request: appsRequest, jwt: jwt)

            guard let app = appsResponse.data.first else {
                errorMessage = AppStoreConnectError.appNotFound(bundleId).localizedDescription
                isLoading = false
                return
            }

            // 第二步：使用应用 ID 获取版本列表（不包含详情）
            let versionsRequest = FetchAppVersionsAPI.Request(appId: app.id)
            let versionsResponse = try await FetchAppVersionsAPI.execute(request: versionsRequest, jwt: jwt)

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
        } catch {
            let errorDesc = (error as? AppStoreConnectError)?.localizedDescription ?? error.localizedDescription
            self.errorMessage = errorDesc
        }

        isLoading = false
    }

    /// 修改版本号
    func updateVersion(versionId: String, newVersionString: String) async throws {
        guard isConfigured else {
            throw AppStoreConnectError.jwtGenerationFailed("请先配置 API 密钥")
        }

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
        }
    }

    /// 获取单个版本的详细信息
    func fetchVersionDetail(versionId: String) async {
        guard isConfigured else {
            errorMessage = "请先配置 API 密钥"
            return
        }

        do {
            let jwt = try generateJWT()
            let request = FetchVersionDetailAPI.Request(versionId: versionId)
            let response = try await FetchVersionDetailAPI.execute(request: request, jwt: jwt)

            // 处理 included 资源
            var reviewDetail: AppStoreReviewDetail?
            var localization: AppStoreVersionLocalization?

            if let included = response.included {
                for resource in included {
                    switch resource {
                    case let .appStoreReviewDetail(reviewData):
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
            }

        } catch {
            let errorDesc = (error as? AppStoreConnectError)?.localizedDescription ?? error.localizedDescription
            errorMessage = errorDesc
        }
    }
}
