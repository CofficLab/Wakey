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
