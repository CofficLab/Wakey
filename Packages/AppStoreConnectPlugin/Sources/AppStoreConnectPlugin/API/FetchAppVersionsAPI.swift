import Foundation

/// 获取应用版本信息 API
///
/// 通过应用 ID 获取 App Store 版本信息
///
/// 文档: https://developer.apple.com/documentation/appstoreconnectapi/get-v1-apps-_id_-appstoreversions
///
/// 可用字段 (fields[appStoreVersions]):
/// - platform: 平台 (IOS, MAC_OS, TV_OS, VISION_OS)
/// - versionString: 版本号字符串
/// - appStoreState: App Store 状态
/// - appVersionState: 版本状态
/// - createdDate: 创建日期
/// - releaseType: 发布类型 (MANUAL, AUTO, AFTER_APPROVAL)
/// - downloadable: 是否可下载
/// - copyright: 版权信息
/// - reviewType: 审核类型
/// - earliestReleaseDate: 最早发布日期
/// - usesIdfa: 是否使用 IDFA
/// - ageRatingDeclaration: 年龄评级声明
///
/// 应用字段 (fields[apps]):
/// - name: 应用名称
/// - bundleId: Bundle ID
/// - sku: SKU
/// - primaryLocale: 主要语言环境
/// - isOrEverWasMadeForKids: 是否为儿童应用
/// - subscriptionStatusUrl: 订阅状态 URL
///
/// 审核详情字段 (fields[appStoreReviewDetails]):
/// - contactFirstName: 联系人名
/// - contactLastName: 联系人姓
/// - contactPhone: 联系电话
/// - contactEmail: 联系邮箱
/// - demoAccountRequired: 是否需要演示账号
/// - demoAccountName: 演示账号名
/// - demoAccountPassword: 演示账号密码
/// - notes: 备注
struct FetchAppVersionsAPI {
    struct Request {
        let appId: String
        let limit: Int = 20

        var url: URL? {
            var components = URLComponents(string: "\(AppStoreConnectAPI.baseURL)/apps/\(appId)/appStoreVersions")
            components?.queryItems = [
                URLQueryItem(name: "limit", value: String(limit))
                // 不包含详细信息，按需加载
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
        case appStoreReviewDetail(AppStoreReviewDetailData)
        case appStoreVersionLocalization(AppStoreVersionLocalizationData)
        case unknown

        init(from decoder: Decoder) throws {
            // 先读取 type 字段来判断资源类型
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)

            switch type {
            case "apps":
                let appData = try AppData(from: decoder)
                self = .app(appData)
            case "appStoreReviewDetails":
                let reviewData = try AppStoreReviewDetailData(from: decoder)
                self = .appStoreReviewDetail(reviewData)
            case "appStoreVersionLocalizations":
                let localizationData = try AppStoreVersionLocalizationData(from: decoder)
                self = .appStoreVersionLocalization(localizationData)
            default:
                self = .unknown
            }
        }

        private enum CodingKeys: String, CodingKey {
            case type
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
            let response = try AppStoreConnectAPI.decoder.decode(Response.self, from: data)

            // 调试：打印原始响应
            if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
               let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("\n=== API 响应 (JSON) ===")
                print(jsonString)
                print("========================\n")
            }

            return response
        } catch {
            throw AppStoreConnectError.networkError(error)
        }
    }
}
