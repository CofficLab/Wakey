import Foundation

/// 获取应用版本信息 API
///
/// 通过应用 ID 获取 App Store 版本信息
///
/// 文档: https://developer.apple.com/documentation/appstoreconnectapi/get-v1-apps-_id_-appstoreversions
///
/// 可用字段:
/// - platform: 平台 (IOS, MAC_OS, TV_OS, VISION_OS)
/// - versionString: 版本号字符串
/// - appStoreState: App Store 状态
/// - createdDate: 创建日期
/// - releaseType: 发布类型 (MANUAL, AUTO, AFTER_APPROVAL)
/// - downloadable: 是否可下载
///
/// 应用字段 (fields[apps]):
/// - name: 应用名称
/// - bundleId: Bundle ID
/// - sku: SKU
/// - primaryLocale: 主要语言环境
/// - isOrEverWasMadeForKids: 是否为儿童应用
/// - subscriptionStatusUrl: 订阅状态 URL
struct FetchAppVersionsAPI {
    struct Request {
        let appId: String
        let limit: Int = 20

        var url: URL? {
            var components = URLComponents(string: "\(AppStoreConnectAPI.baseURL)/apps/\(appId)/appStoreVersions")
            components?.queryItems = [
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "fields[appStoreVersions]", value: "platform,versionString,appStoreState,createdDate,releaseType,downloadable"),
                URLQueryItem(name: "fields[apps]", value: "name,bundleId,sku,primaryLocale,isOrEverWasMadeForKids"),
                URLQueryItem(name: "include", value: "app")
            ]
            return components?.url
        }
    }

    struct Response: Decodable {
        let data: [AppStoreVersionData]
        let included: [IncludedResource]?
        let links: ResponseLinks?
        let meta: ResponseMeta?
    }

    /// 包含的资源类型
    enum IncludedResource: Decodable {
        case app(AppData)
        case unknown

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let appData = try? container.decode(AppData.self) {
                self = .app(appData)
            } else {
                self = .unknown
            }
        }
    }

    /// 执行 API 请求
    static func execute(request: Request, jwt: String) async throws -> Response {
        guard let url = request.url else {
            throw AppStoreConnectError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppStoreConnectError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let responseBody = String(data: data, encoding: .utf8)
            throw AppStoreConnectError.apiError(
                statusCode: httpResponse.statusCode,
                responseBody: responseBody,
                requestURL: url.absoluteString,
                jwt: jwt
            )
        }

        do {
            return try AppStoreConnectAPI.decoder.decode(Response.self, from: data)
        } catch {
            throw AppStoreConnectError.networkError(error)
        }
    }
}
