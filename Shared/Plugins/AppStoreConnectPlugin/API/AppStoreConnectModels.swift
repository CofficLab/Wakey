import Foundation

// MARK: - 通用响应结构

struct PagedResponse<T: Decodable>: Decodable {
    let data: [T]
    let links: ResponseLinks?
    let meta: ResponseMeta?
}

struct ResponseLinks: Decodable {
    let selfLink: String?

    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
    }
}

struct ResponseMeta: Decodable {
    let paging: PagingMeta?
}

struct PagingMeta: Decodable {
    let total: Int?
    let limit: Int?
}

// MARK: - 应用相关模型

struct AppData: Decodable {
    let type: String
    let id: String
    let attributes: AppAttributes?
    let relationships: AppRelationships?
}

struct AppAttributes: Decodable {
    let bundleId: String?
    let name: String?
    let sku: String?
    let appStoreStates: [String]?
}

struct AppRelationships: Decodable {
    let appStoreVersions: AppStoreVersionsLink?
}

struct AppStoreVersionsLink: Decodable {
    let links: LinkObjects?
    let data: [RelationshipData]?
}

struct LinkObjects: Decodable {
    let selfLink: String?
    let related: String?

    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case related
    }
}

struct RelationshipData: Decodable {
    let type: String
    let id: String
}

// MARK: - 版本相关模型

struct AppStoreVersionData: Decodable {
    let id: String
    let attributes: AppStoreVersionAttributes
}

struct AppStoreVersionAttributes: Decodable {
    let platform: String
    let versionString: String
    let appStoreState: String
    let createdDate: String
    let releaseType: String?
    let downloadable: Bool?
}

// MARK: - 业务模型

/// 应用信息（用于 UI 展示）
struct AppInfo {
    let id: String
    let name: String
    let bundleId: String
    let sku: String
    let appStoreStates: [String]
}

struct AppStoreVersion {
    let id: String
    let platform: String
    let versionString: String
    let appStoreState: String
    let createdDate: String
    let releaseType: String
    let downloadable: Bool?
}
