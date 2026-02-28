import Foundation

// MARK: - 应用管理

extension AppStoreConnectService {
    /// 获取所有应用列表
    func fetchAllApps() async {
        guard isConfigured else {
            appsError = "请先配置 API 密钥"
            return
        }

        isLoadingApps = true
        appsError = nil

        do {
            // 生成 JWT
            let jwt = try generateJWT()

            // 获取所有应用
            let appsRequest = FetchAllAppsAPI.Request()

            let appsResponse = try await FetchAllAppsAPI.execute(request: appsRequest, jwt: jwt)

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

            for app in apps {
                print("  - \(app.name) (\(app.bundleId))")
            }

        } catch {
            // 忽略取消错误，这是正常行为
            if (error as? CancellationError) != nil {
                return
            }
            let errorDesc = (error as? AppStoreConnectError)?.localizedDescription ?? error.localizedDescription
            self.appsError = errorDesc
        }

        isLoadingApps = false
    }
}
