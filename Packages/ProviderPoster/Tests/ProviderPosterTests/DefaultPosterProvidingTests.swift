import SwiftUI
import Testing
@testable import ProviderPoster

private func makePoster(
    id: String,
    title: String,
    subtitle: String? = nil,
    order: Int = 0
) -> PosterViewConfiguration {
    PosterViewConfiguration(id: id, title: title, subtitle: subtitle, order: order) {
        Text(title)
    }
}

@Suite("PosterViewConfiguration")
@MainActor
struct PosterViewConfigurationTests {
    @Test("保留 id / title / order")
    func storesProperties() {
        let poster = makePoster(id: "wakey", title: "Wakey", order: 10)
        #expect(poster.id == "wakey")
        #expect(poster.title == "Wakey")
        #expect(poster.order == 10)
    }

    @Test("subtitle 默认为 nil")
    func subtitleDefaultsToNil() {
        let poster = makePoster(id: "a", title: "A")
        #expect(poster.subtitle == nil)
    }

    @Test("可显式携带 subtitle")
    func carriesSubtitle() {
        let poster = makePoster(id: "a", title: "A", subtitle: "副标题")
        #expect(poster.subtitle == "副标题")
    }

    @Test("order 默认为 0")
    func orderDefaultsToZero() {
        let poster = makePoster(id: "a", title: "A")
        #expect(poster.order == 0)
    }

    @Test("content 可被调用并返回 AnyView")
    func contentIsInvocable() {
        let poster = makePoster(id: "a", title: "A")
        let view = poster.content()
        #expect(type(of: view) == AnyView.self)
    }

    @Test("content 可重复调用且返回一致")
    func contentIsRepeatable() {
        let poster = makePoster(id: "a", title: "A")
        // content 捕获的是逃逸闭包，重复调用必须每次都产出等价的 AnyView，
        // 否则 SwiftUI 会在 diff 时把海报视为身份不稳定的内容。
        let first = poster.content()
        let second = poster.content()
        #expect(type(of: first) == type(of: second))
        #expect(type(of: first) == AnyView.self)
    }

    @Test("作为 Identifiable 可直接用于列表")
    func conformsToIdentifiable() {
        let poster = makePoster(id: "unique", title: "A")
        #expect(poster.id == "unique")
    }
}

@Suite("DefaultPosterProviding")
@MainActor
struct DefaultPosterProvidingTests {
    @Test("初始状态没有海报")
    func startsEmpty() {
        let provider = DefaultPosterProviding()
        #expect(provider.posters.isEmpty)
    }

    @Test("海报按 order 升序返回")
    func sortsByOrder() {
        let provider = DefaultPosterProviding()
        provider.addPoster(ownerID: "a", makePoster(id: "c", title: "C", order: 30))
        provider.addPoster(ownerID: "a", makePoster(id: "a", title: "A", order: 10))
        provider.addPoster(ownerID: "a", makePoster(id: "b", title: "B", order: 20))

        #expect(provider.posters.map(\.id) == ["a", "b", "c"])
    }

    @Test("多个 owner 的贡献按 order 合并排序")
    func mergesOwnersByOrder() {
        let provider = DefaultPosterProviding()
        provider.addPoster(ownerID: "a", makePoster(id: "a", title: "A", order: 20))
        provider.addPoster(ownerID: "b", makePoster(id: "b", title: "B", order: 10))

        #expect(provider.posters.map(\.id) == ["b", "a"])
    }

    @Test("相同 order 保持注册顺序（排序稳定）")
    func equalOrdersKeepRegistrationOrder() {
        let provider = DefaultPosterProviding()
        provider.addPoster(ownerID: "a", makePoster(id: "first", title: "First", order: 5))
        provider.addPoster(ownerID: "a", makePoster(id: "second", title: "Second", order: 5))
        provider.addPoster(ownerID: "a", makePoster(id: "third", title: "Third", order: 5))

        #expect(provider.posters.map(\.id) == ["first", "second", "third"])
    }

    @Test("撤回只移除对应 owner 的贡献")
    func removesOnlyMatchingOwner() {
        let provider = DefaultPosterProviding()
        provider.addPoster(ownerID: "a", makePoster(id: "a", title: "A", order: 1))
        provider.addPoster(ownerID: "b", makePoster(id: "b", title: "B", order: 2))

        provider.removePosters(ownerID: "a")

        #expect(provider.posters.map(\.id) == ["b"])
    }

    @Test("撤回未注册过的 owner 是安全的空操作")
    func removingUnknownOwnerIsNoOp() {
        let provider = DefaultPosterProviding()
        provider.addPoster(ownerID: "a", makePoster(id: "a", title: "A"))

        provider.removePosters(ownerID: "unknown")

        #expect(provider.posters.count == 1)
    }

    @Test("撤回空 owner 前缀不会误伤其他 owner")
    func doesNotMatchOwnerByPrefix() {
        let provider = DefaultPosterProviding()
        provider.addPoster(ownerID: "poster.a", makePoster(id: "a", title: "A", order: 1))
        provider.addPoster(ownerID: "poster.ab", makePoster(id: "b", title: "B", order: 2))

        provider.removePosters(ownerID: "poster.a")

        #expect(provider.posters.map(\.id) == ["b"])
    }

    @Test("撤回后重新贡献可再次累积")
    func supportsRecontribution() {
        let provider = DefaultPosterProviding()
        provider.addPoster(ownerID: "a", makePoster(id: "a", title: "A", order: 1))
        provider.removePosters(ownerID: "a")
        provider.addPoster(ownerID: "a", makePoster(id: "b", title: "B", order: 1))

        #expect(provider.posters.map(\.id) == ["b"])
    }

    @Test("重复撤回同一 owner 幂等")
    func repeatedRemovalIsIdempotent() {
        let provider = DefaultPosterProviding()
        provider.addPoster(ownerID: "a", makePoster(id: "a", title: "A"))
        provider.addPoster(ownerID: "a", makePoster(id: "a2", title: "A2"))

        provider.removePosters(ownerID: "a")
        provider.removePosters(ownerID: "a")

        #expect(provider.posters.isEmpty)
    }
}
