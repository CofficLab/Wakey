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
}
