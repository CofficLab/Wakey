import Foundation

/// 修改应用版本信息 API
///
/// 通过版本 ID 修改 App Store 版本信息
///
/// 文档: https://developer.apple.com/documentation/appstoreconnectapi/patch-v1-appstoreversions-_id_
///
/// 可修改的属性 (attributes):
/// - versionString: 版本号字符串 (如 "1.0.1")
/// - copyright: 版权信息
/// - releaseType: 发布类型 (MANUAL, AFTER_APPROVAL, SCHEDULED)
/// - earliestReleaseDate: 计划发布日期
/// - downloadable: 是否可下载
///
/// 注意：
/// - 只能修改特定状态的版本（如 PREPARED_FOR_SUBMISSION、WAITING_FOR_REVIEW）
/// - 已发布或正在审核的版本通常不能修改版本号
struct UpdateAppVersionAPI {
    struct Request {
        let versionId: String
        let versionString: String?
        let copyright: String?
        let releaseType: String?
        let earliestReleaseDate: Date?
        let downloadable: Bool?

        var url: URL? {
            return URL(string: "\(AppStoreConnectAPI.baseURL)/appStoreVersions/\(versionId)")
        }

        func httpBody() throws -> Data {
            var attributes: [String: Any?] = [:]

            if let versionString = versionString {
                attributes["versionString"] = versionString
            }
            if let copyright = copyright {
                attributes["copyright"] = copyright
            }
            if let releaseType = releaseType {
                attributes["releaseType"] = releaseType
            }
            if let earliestReleaseDate = earliestReleaseDate {
                let isoFormatter = ISO8601DateFormatter()
                isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                attributes["earliestReleaseDate"] = isoFormatter.string(from: earliestReleaseDate)
            }
            if let downloadable = downloadable {
                attributes["downloadable"] = downloadable
            }

            let requestBody: [String: Any] = [
                "data": [
                    "type": "appStoreVersions",
                    "id": versionId,
                    "attributes": attributes
                ]
            ]

            return try JSONSerialization.data(withJSONObject: requestBody, options: [.prettyPrinted])
        }
    }

    struct Response: Decodable {
        let data: AppStoreVersionData
        let included: [FetchAppVersionsAPI.IncludedResource]?
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
