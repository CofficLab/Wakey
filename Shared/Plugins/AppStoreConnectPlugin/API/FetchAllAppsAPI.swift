import Foundation

/// 获取所有应用列表 API
/// 不使用过滤条件，返回账户下所有应用
struct FetchAllAppsAPI {
    struct Request {
        let limit: Int = 50

        var url: URL? {
            var components = URLComponents(string: "\(AppStoreConnectAPI.baseURL)/apps")
            components?.queryItems = [
                URLQueryItem(name: "limit", value: String(limit)),
                // 按名称排序
                URLQueryItem(name: "sort", value: "name")
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
