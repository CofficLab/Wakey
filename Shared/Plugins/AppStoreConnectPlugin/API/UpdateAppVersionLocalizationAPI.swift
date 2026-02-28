import Foundation

/// 修改应用版本本地化信息 API
///
/// 通过本地化 ID 修改 App Store 版本本地化信息
///
/// 文档: https://developer.apple.com/documentation/appstoreconnectapi/patch-v1-appstoreversionlocalizations-_id_
///
/// 可修改的属性 (attributes):
/// - description: 版本描述
/// - keywords: 关键词
/// - marketingUrl: 营销网址
/// - promotionalText: 推广文本
/// - supportUrl: 技术支持网址
/// - whatsNew: 更新说明
struct UpdateAppVersionLocalizationAPI {
    struct Request {
        let localizationId: String
        let description: String?
        let keywords: String?
        let marketingUrl: String?
        let promotionalText: String?
        let supportUrl: String?
        let whatsNew: String?

        var url: URL? {
            return URL(string: "\(AppStoreConnectAPI.baseURL)/appStoreVersionLocalizations/\(localizationId)")
        }

        func httpBody() throws -> Data {
            var attributes: [String: String?] = [:]

            if let description = description {
                attributes["description"] = description
            }
            if let keywords = keywords {
                attributes["keywords"] = keywords
            }
            if let marketingUrl = marketingUrl {
                attributes["marketingUrl"] = marketingUrl
            }
            if let promotionalText = promotionalText {
                attributes["promotionalText"] = promotionalText
            }
            if let supportUrl = supportUrl {
                attributes["supportUrl"] = supportUrl
            }
            if let whatsNew = whatsNew {
                attributes["whatsNew"] = whatsNew
            }

            let requestBody: [String: Any] = [
                "data": [
                    "type": "appStoreVersionLocalizations",
                    "id": localizationId,
                    "attributes": attributes
                ]
            ]

            return try JSONSerialization.data(withJSONObject: requestBody, options: [.prettyPrinted])
        }
    }

    struct Response: Decodable {
        let data: AppStoreVersionLocalizationData
    }

    /// 执行 API 请求
    static func execute(request: Request, jwt: String) async throws -> Response {
        guard let url = request.url else {
            throw AppStoreConnectError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        urlRequest.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            urlRequest.httpBody = try request.httpBody()
        } catch {
            throw AppStoreConnectError.networkError(error)
        }

        // 调试：打印请求
        if let body = urlRequest.httpBody,
           let json = try? JSONSerialization.jsonObject(with: body, options: .allowFragments),
           let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("\n=== API 请求 (PATCH) ===")
            print("URL: \(url.absoluteString)")
            print("Body:")
            print(jsonString)
            print("========================\n")
        }

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
            let decoded = try AppStoreConnectAPI.decoder.decode(Response.self, from: data)

            // 调试：打印响应
            if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
               let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("\n=== API 响应 (JSON) ===")
                print(jsonString)
                print("========================\n")
            }

            return decoded
        } catch {
            throw AppStoreConnectError.networkError(error)
        }
    }
}
