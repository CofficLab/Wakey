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
