import Foundation
import SwiftUI
import CryptoKit
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

    // MARK: - JWT 生成

    func generateJWT() throws -> String {
        guard !apiKey.isEmpty, !issuerId.isEmpty else {
            throw AppStoreConnectError.jwtGenerationFailed("API 密钥或 Issuer ID 为空")
        }

        // 检查 API 密钥格式
        let trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedKey.contains("-----BEGIN PRIVATE KEY-----") else {
            throw AppStoreConnectError.jwtGenerationFailed("API 密钥格式错误：应包含 '-----BEGIN PRIVATE KEY-----' 头部")
        }
        guard trimmedKey.contains("-----END PRIVATE KEY-----") else {
            throw AppStoreConnectError.jwtGenerationFailed("API 密钥格式错误：应包含 '-----END PRIVATE KEY-----' 尾部")
        }
        guard trimmedKey.contains("\n") else {
            throw AppStoreConnectError.jwtGenerationFailed("API 密钥格式错误：密钥应包含换行符")
        }

        // 检查 Issuer ID 格式
        guard issuerId.contains("-") || issuerId.count >= 10 else {
            throw AppStoreConnectError.jwtGenerationFailed("Issuer ID 格式错误：看起来不正确（应为 UUID 格式）")
        }

        // 从私钥中提取 Key ID（假设已经存储）
        // TODO: 需要在配置中添加 keyId 字段
        guard let keyId = getKeyId() else {
            throw AppStoreConnectError.jwtGenerationFailed("未配置 Key ID (kid)")
        }

        let header = ["alg": "ES256", "typ": "JWT", "kid": keyId]
        let now = Date()
        // Apple 规定 JWT 有效期最长 20 分钟
        let expiration = now.addingTimeInterval(1200)

        let payload: [String: Any] = [
            "iss": issuerId,
            "iat": Int(now.timeIntervalSince1970),
            "exp": Int(expiration.timeIntervalSince1970),
            "aud": "appstoreconnect-v1",
        ]

        guard let headerData = try? JSONSerialization.data(withJSONObject: header) else {
            throw AppStoreConnectError.jwtGenerationFailed("JWT header 序列化失败")
        }

        guard let payloadData = try? JSONSerialization.data(withJSONObject: payload) else {
            throw AppStoreConnectError.jwtGenerationFailed("JWT payload 序列化失败")
        }

        let headerBase64 = headerData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")

        let payloadBase64 = payloadData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")

        let signingInput = "\(headerBase64).\(payloadBase64)"

        guard let signingData = signingInput.data(using: .utf8) else {
            throw AppStoreConnectError.jwtGenerationFailed("签名数据转换失败")
        }

        // 使用 CryptoKit 加载私钥并签名
        let privateKey = try loadPrivateKey()
        let signature = try privateKey.signature(for: signingData)

        // CryptoKit 的 rawRepresentation 返回 DER 编码的签名
        // JWT ES256 需要将 DER 转换为 raw r|s 格式（64 字节）
        let derSignature = signature.rawRepresentation
        let signatureData = convertDERToRaw(derSignature)

        print("\n签名调试信息:")
        print("  签名算法: ES256 (ECDSA with SHA-256)")
        print("  DER 签名长度: \(derSignature.count) 字节")
        print("  Raw 签名长度: \(signatureData.count) 字节")
        print("  签名 (hex): \(signatureData.map { String(format: "%02hhx", $0) }.joined(separator: ""))")

        let signatureBase64 = signatureData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")

        print("  签名 Base64: \(signatureBase64)")

        return "\(signingInput).\(signatureBase64)"
    }

    /// 使用 CryptoKit 加载 EC P-256 私钥
    private func loadPrivateKey() throws -> P256.Signing.PrivateKey {
        // 去除 PEM 头尾和空白字符
        var trimmedKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)

        // 移除 PEM 头部
        trimmedKey = trimmedKey.replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "")
        trimmedKey = trimmedKey.replacingOccurrences(of: "-----BEGIN EC PRIVATE KEY-----", with: "")

        // 移除 PEM 尾部
        trimmedKey = trimmedKey.replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
        trimmedKey = trimmedKey.replacingOccurrences(of: "-----END EC PRIVATE KEY-----", with: "")

        // 去除换行符和空白
        trimmedKey = trimmedKey.replacingOccurrences(of: "\n", with: "")
        trimmedKey = trimmedKey.replacingOccurrences(of: "\r", with: "")
        trimmedKey = trimmedKey.trimmingCharacters(in: .whitespaces)

        // Base64 解码
        guard let derData = Data(base64Encoded: trimmedKey) else {
            throw NSError(domain: "JWT", code: -1, userInfo: [NSLocalizedDescriptionKey: "Base64 解码失败"])
        }

        // 从 DER 数据中提取裸私钥（32字节）
        let privateKeyBytes = extractPrivateKeyFromDER(derData)

        // 使用 CryptoKit 创建私钥
        return try P256.Signing.PrivateKey(rawRepresentation: privateKeyBytes)
    }

    /// 从 PKCS#8/SEC1 DER 数据中提取裸私钥（32字节）
    private func extractPrivateKeyFromDER(_ derData: Data) -> Data {
        let bytes = [UInt8](derData)

        // 首先找到 OCTET STRING (0x04) 标记
        for i in 0..<(bytes.count - 2) {
            if bytes[i] == 0x02 && bytes[i + 1] == 0x01 && bytes[i + 2] == 0x01 {
                // 找到 version INTEGER (02 01 01)
                // 下一个应该是 OCTET STRING (04 20 [32 bytes])
                if i + 3 < bytes.count && bytes[i + 3] == 0x04 && bytes[i + 4] == 0x20 {
                    let privateKeyStart = i + 5
                    if privateKeyStart + 32 <= bytes.count {
                        return Data(bytes[privateKeyStart..<(privateKeyStart + 32)])
                    }
                }
            }
        }

        // 回退：尝试从中间提取
        if derData.count > 40 {
            let offset = 27 + 7  // PKCS#8 header + SEC1 header
            if offset + 32 <= derData.count {
                let potentialKey = derData.subdata(in: offset..<(offset + 32))
                if potentialKey.contains(where: { $0 != 0 }) {
                    return potentialKey
                }
            }
        }

        // 最后的回退
        return derData.prefix(32)
    }

    /// 将 DER 编码的 ECDSA 签名转换为 JWT 需要的 raw r|s 格式
    private func convertDERToRaw(_ derSignature: Data) -> Data {
        let bytes = [UInt8](derSignature)

        // DER 结构: 30 [len] 02 [r-len] [r] 02 [s-len] [s]
        guard bytes.count >= 8 && bytes[0] == 0x30 else {
            return derSignature  // 可能已经是正确格式
        }

        var index = 1  // 跳过 0x30

        // 读取总长度
        if bytes[index] > 0x80 {
            index += 1 + Int(bytes[index] & 0x7f)  // 长格式
        } else {
            index += 1  // 短格式
        }

        // 读取 r
        guard bytes[index] == 0x02 else { return derSignature }
        index += 1  // 跳过 0x02

        let rLen = Int(bytes[index])
        index += 1

        var r = Data(bytes[index..<(index + rLen)])
        index += rLen

        // 如果 r 有前导零，去除
        while r.count > 32 && r.first == 0 {
            r.removeFirst()
        }

        // 读取 s
        guard index < bytes.count && bytes[index] == 0x02 else { return derSignature }
        index += 1  // 跳过 0x02

        let sLen = Int(bytes[index])
        index += 1

        var s = Data(bytes[index..<(index + sLen)])

        // 如果 s 有前导零，去除
        while s.count > 32 && s.first == 0 {
            s.removeFirst()
        }

        // 填充到 32 字节
        while r.count < 32 {
            r.insert(0x00, at: 0)
        }
        while s.count < 32 {
            s.insert(0x00, at: 0)
        }

        return r + s
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
            print("\nJWT 详情:")
            print("  完整 JWT: \(jwt)")
            print("  JWT 长度: \(jwt.count) 字符")

            // 解析 JWT 显示 payload
            if let payloadData = decodeJWTPayload(jwt),
               let payload = try? JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any] {
                print("\nJWT Payload:")
                if let json = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted]),
                   let pretty = String(data: json, encoding: .utf8) {
                    print(pretty)
                }

                // 检查过期时间
                if let exp = payload["exp"] as? Int {
                    let expDate = Date(timeIntervalSince1970: TimeInterval(exp))
                    print("JWT 过期时间: \(ISO8601DateFormatter().string(from: expDate))")
                    print("距离过期: \(Int(expDate.timeIntervalSinceNow)) 秒")
                }
            }

            // 第一步：通过 Bundle ID 获取应用 ID
            let appsRequest = FetchAppsAPI.Request(bundleId: bundleId)
            print("\n第一步请求: 获取应用 ID")
            print("  URL: \(appsRequest.url?.absoluteString ?? "无效")")

            let appsResponse = try await FetchAppsAPI.execute(request: appsRequest, jwt: jwt)
            print("  成功！返回 \(appsResponse.data.count) 个应用")

            guard let app = appsResponse.data.first else {
                errorMessage = AppStoreConnectError.appNotFound(bundleId).localizedDescription
                isLoading = false
                return
            }

            print("  应用 ID: \(app.id)")
            print("  应用名称: \(app.attributes?.name ?? "未知")")

            // 第二步：使用应用 ID 获取版本信息
            let versionsRequest = FetchAppVersionsAPI.Request(appId: app.id)
            print("\n第二步请求: 获取版本信息")
            print("  URL: \(versionsRequest.url?.absoluteString ?? "无效")")

            let versionsResponse = try await FetchAppVersionsAPI.execute(request: versionsRequest, jwt: jwt)
            print("  成功！返回 \(versionsResponse.data.count) 个版本")

            // 清空之前的审核详情
            versionReviewDetails = [:]

            // 从 included 中提取应用信息和审核详情
            if let included = versionsResponse.included {
                for resource in included {
                    switch resource {
                    case .app(let appData):
                        currentApp = AppInfo(
                            id: appData.id,
                            name: appData.attributes?.name ?? "未知",
                            bundleId: appData.attributes?.bundleId ?? "",
                            sku: appData.attributes?.sku ?? "",
                            appStoreStates: appData.attributes?.appStoreStates ?? [],
                            primaryLocale: appData.attributes?.primaryLocale,
                            isOrEverWasMadeForKids: appData.attributes?.isOrEverWasMadeForKids,
                            subscriptionStatusUrl: appData.attributes?.subscriptionStatusUrl
                        )
                        print("  应用名称: \(currentApp?.name ?? "")")
                        print("  Bundle ID: \(currentApp?.bundleId ?? "")")
                        if let locale = currentApp?.primaryLocale {
                            print("  主要语言: \(locale)")
                        }

                    case .appStoreReviewDetail(let reviewData):
                        // 从 relationships 中获取关联的版本 ID
                        let reviewDetail = AppStoreReviewDetail(
                            contactFirstName: reviewData.attributes.contactFirstName,
                            contactLastName: reviewData.attributes.contactLastName,
                            contactPhone: reviewData.attributes.contactPhone,
                            contactEmail: reviewData.attributes.contactEmail,
                            demoAccountRequired: reviewData.attributes.demoAccountRequired,
                            demoAccountName: reviewData.attributes.demoAccountName,
                            demoAccountPassword: reviewData.attributes.demoAccountPassword,
                            notes: reviewData.attributes.notes
                        )

                        // 尝试从 API 响应中找到关联的版本 ID
                        // 如果没有明确关联，将此审核详情用于所有版本
                        versionReviewDetails[reviewData.id] = reviewDetail
                        print("  审核详情已加载 (ID: \(reviewData.id))")

                    case .unknown:
                        break
                    }
                }
            }

            // 转换为业务模型
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
                    usesIdfa: item.attributes.usesIdfa
                )
            }

            print("\n=== API 请求成功完成 ===")

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
