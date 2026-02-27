import Foundation

/// 获取单个版本详细信息 API
/// https://developer.apple.com/documentation/appstoreconnectapi/get-v1-appstoreversions-_id_
struct FetchVersionDetailAPI {
    struct Request {
        let versionId: String

        var url: URL? {
            var components = URLComponents(string: "\(AppStoreConnectAPI.baseURL)/appStoreVersions/\(versionId)")
            components?.queryItems = [
                URLQueryItem(
                    name: "fields[appStoreVersions]",
                    value: "platform,versionString,appStoreState,createdDate,releaseType,uploadedDate,usesNonExemptEncryption,downloadable"
                )
            ]
            return components?.url
        }
    }

    struct Response: Decodable {
        let data: AppStoreVersionDetailData
        let links: ResponseLinks?
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

/// 版本详细信息数据
struct AppStoreVersionDetailData: Decodable {
    let id: String
    let attributes: AppStoreVersionDetailAttributes
}

/// 版本详细信息属性
struct AppStoreVersionDetailAttributes: Decodable {
    let platform: String
    let versionString: String
    let appStoreState: String
    let createdDate: String
    let releaseType: String?
    let uploadedDate: String?
    let usesNonExemptEncryption: Bool?
    let downloadable: Bool?
}
