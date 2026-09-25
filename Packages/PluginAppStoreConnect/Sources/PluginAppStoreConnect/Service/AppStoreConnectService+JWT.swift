import CryptoKit
import Foundation

// MARK: - JWT 生成

extension AppStoreConnectService {
    /// 生成 JWT token 用于 API 认证
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

        // 获取 Key ID
        let keyId: String
        if !self.keyId.isEmpty {
            keyId = self.keyId
        } else {
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

        guard let signingData: Data = signingInput.data(using: .utf8) else {
            throw AppStoreConnectError.jwtGenerationFailed("签名数据转换失败")
        }

        // 使用 CryptoKit 加载私钥并签名
        let privateKey = try loadPrivateKey()
        let signature = try privateKey.signature(for: signingData)

        // CryptoKit 的 rawRepresentation 返回 DER 编码的签名
        // JWT ES256 需要将 DER 转换为 raw r|s 格式（64 字节）
        let derSignature = signature.rawRepresentation
        let signatureData = convertDERToRaw(derSignature)

        let signatureBase64 = signatureData.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")

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
        for i in 0 ..< (bytes.count - 2) {
            if bytes[i] == 0x02 && bytes[i + 1] == 0x01 && bytes[i + 2] == 0x01 {
                // 找到 version INTEGER (02 01 01)
                // 下一个应该是 OCTET STRING (04 20 [32 bytes])
                if i + 3 < bytes.count && bytes[i + 3] == 0x04 && bytes[i + 4] == 0x20 {
                    let privateKeyStart = i + 5
                    if privateKeyStart + 32 <= bytes.count {
                        return Data(bytes[privateKeyStart ..< (privateKeyStart + 32)])
                    }
                }
            }
        }

        // 回退：尝试从中间提取
        if derData.count > 40 {
            let offset = 27 + 7 // PKCS#8 header + SEC1 header
            if offset + 32 <= derData.count {
                let potentialKey = derData.subdata(in: offset ..< (offset + 32))
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
            return derSignature // 可能已经是正确格式
        }

        var index = 1 // 跳过 0x30

        // 读取总长度
        if bytes[index] > 0x80 {
            index += 1 + Int(bytes[index] & 0x7F) // 长格式
        } else {
            index += 1 // 短格式
        }

        // 读取 r
        guard bytes[index] == 0x02 else { return derSignature }
        index += 1 // 跳过 0x02

        let rLen = Int(bytes[index])
        index += 1

        var r = Data(bytes[index ..< (index + rLen)])
        index += rLen

        // 如果 r 有前导零，去除
        while r.count > 32 && r.first == 0 {
            r.removeFirst()
        }

        // 读取 s
        guard index < bytes.count && bytes[index] == 0x02 else { return derSignature }
        index += 1 // 跳过 0x02

        let sLen = Int(bytes[index])
        index += 1

        var s = Data(bytes[index ..< (index + sLen)])

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
}
