import Foundation

/// App Store Connect API 基础配置
enum AppStoreConnectAPI {
    static let baseURL = "https://api.appstoreconnect.apple.com/v1"
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

/// App Store Connect API 错误
enum AppStoreConnectError: LocalizedError {
    case invalidURL
    case invalidResponse
    case jwtGenerationFailed(String)
    case apiError(statusCode: Int, responseBody: String?, requestURL: String?, jwt: String?)
    case appNotFound(String)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL 构建失败"
        case .invalidResponse:
            return "无效的响应"
        case .jwtGenerationFailed(let message):
            return "JWT 生成失败：\(message)"
        case .apiError(let statusCode, let responseBody, let requestURL, let jwt):
            var desc = "API 请求失败 (状态码: \(statusCode))\n\n"

            if let url = requestURL {
                desc += "请求 URL: \(url)\n"
            }

            if let body = responseBody {
                desc += "\n响应内容:\n\(formatJSON(body))\n"
            }

            if let token = jwt {
                let jwtPreview = String(token.prefix(50)) + "..."
                desc += "\nJWT (前50字符): \(jwtPreview)"
            }

            return desc
        case .appNotFound(let bundleId):
            return "未找到 Bundle ID 为 \(bundleId) 的应用"
        case .networkError(let error):
            return "网络错误：\(error.localizedDescription)"
        }
    }

    private func formatJSON(_ string: String) -> String {
        guard let data = string.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]),
              let pretty = String(data: prettyData, encoding: .utf8) else {
            return string
        }
        return pretty
    }
}
