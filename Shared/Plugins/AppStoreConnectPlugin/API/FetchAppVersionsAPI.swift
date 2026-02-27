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
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "fields[appStoreVersions]", value: "platform,versionString,appStoreState,appVersionState,copyright,releaseType,downloadable,createdDate,usesIdfa"),
                URLQueryItem(name: "fields[apps]", value: "name,bundleId,sku,primaryLocale,isOrEverWasMadeForKids"),
                URLQueryItem(name: "fields[appStoreReviewDetails]", value: "contactFirstName,contactLastName,contactPhone,contactEmail,demoAccountRequired,demoAccountName,demoAccountPassword,notes"),
                URLQueryItem(name: "include", value: "app,appStoreReviewDetail")
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
        case unknown

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let type = try? container.decode([String: String].self)

            // 尝试根据类型字段判断
            if let typeValue = type?["type"] {
                switch typeValue {
                case "apps":
                    if let appData = try? container.decode(AppData.self) {
                        self = .app(appData)
                        return
                    }
                case "appStoreReviewDetails":
                    if let reviewData = try? container.decode(AppStoreReviewDetailData.self) {
                        self = .appStoreReviewDetail(reviewData)
                        return
                    }
                default:
                    break
                }
            }

            // 回退方案：尝试直接解码
            if let appData = try? container.decode(AppData.self) {
                self = .app(appData)
            } else if let reviewData = try? container.decode(AppStoreReviewDetailData.self) {
                self = .appStoreReviewDetail(reviewData)
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
