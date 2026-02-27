import Foundation

/// 获取应用版本信息 API
/// 通过应用 ID 获取 App Store 版本信息
struct FetchAppVersionsAPI {
    struct Request {
        let appId: String
        let limit: Int = 20

        var url: URL? {
            var components = URLComponents(string: "\(AppStoreConnectAPI.baseURL)/apps/\(appId)/appStoreVersions")
            components?.queryItems = [
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "fields[appStoreVersions]", value: "platform,versionString,appStoreState,createdDate,releaseType")
            ]
            return components?.url
        }
    }

    struct Response: Decodable {
        let data: [AppStoreVersionData]
        let links: ResponseLinks?
        let meta: ResponseMeta?
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
