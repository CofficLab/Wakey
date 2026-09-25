import Foundation

/// 获取应用列表 API
/// 通过 Bundle ID 过滤获取应用信息
struct FetchAppsAPI {
    struct Request {
        let bundleId: String
        let limit: Int = 10

        var url: URL? {
            var components = URLComponents(string: "\(AppStoreConnectAPI.baseURL)/apps")
            components?.queryItems = [
                URLQueryItem(name: "filter[bundleId]", value: bundleId),
                URLQueryItem(name: "limit", value: String(limit))
            ]
            return components?.url
        }
    }

    struct Response: Decodable {
        let data: [AppData]
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
