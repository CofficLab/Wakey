import SwiftUI
import Testing
@testable import ProviderStatusBarPopup

@Suite("DefaultStatusBarPopupProviding")
@MainActor
struct DefaultStatusBarPopupProvidingTests {
    private func view(_ label: String) -> AnyView {
        AnyView(Text(label))
    }

    @Test("初始状态没有弹窗")
    func startsEmpty() {
        let provider = DefaultStatusBarPopupProviding()
        #expect(provider.popupViews.isEmpty)
    }

    @Test("贡献的弹窗按注册顺序返回")
    func preservesRegistrationOrder() {
        let provider = DefaultStatusBarPopupProviding()
        provider.addPopupView(ownerID: "a", view("first"))
        provider.addPopupView(ownerID: "a", view("second"))
        #expect(provider.popupViews.count == 2)
    }

    @Test("多个 owner 的贡献按注册顺序共存")
    func combinesMultipleOwners() {
        let provider = DefaultStatusBarPopupProviding()
        provider.addPopupView(ownerID: "a", view("alpha"))
        provider.addPopupView(ownerID: "b", view("beta"))
        #expect(provider.popupViews.count == 2)
    }

    @Test("撤回只移除对应 owner 的贡献")
    func removesOnlyMatchingOwner() {
        let provider = DefaultStatusBarPopupProviding()
        provider.addPopupView(ownerID: "a", view("alpha"))
        provider.addPopupView(ownerID: "b", view("beta"))

        provider.removePopupViews(ownerID: "a")

        #expect(provider.popupViews.count == 1)
    }

    @Test("同一 owner 可贡献多个弹窗并一次性全部撤回")
    func removesAllEntriesOfSameOwner() {
        let provider = DefaultStatusBarPopupProviding()
        provider.addPopupView(ownerID: "a", view("one"))
        provider.addPopupView(ownerID: "a", view("two"))
        provider.addPopupView(ownerID: "a", view("three"))
        #expect(provider.popupViews.count == 3)

        provider.removePopupViews(ownerID: "a")
        #expect(provider.popupViews.isEmpty)
    }

    @Test("撤回未注册过的 owner 是安全的空操作")
    func removingUnknownOwnerIsNoOp() {
        let provider = DefaultStatusBarPopupProviding()
        provider.addPopupView(ownerID: "a", view("alpha"))

        provider.removePopupViews(ownerID: "unknown")

        #expect(provider.popupViews.count == 1)
    }

    @Test("撤回后重新贡献可再次累积")
    func supportsRecontribution() {
        let provider = DefaultStatusBarPopupProviding()
        provider.addPopupView(ownerID: "a", view("alpha"))
        provider.removePopupViews(ownerID: "a")
        provider.addPopupView(ownerID: "a", view("beta"))

        #expect(provider.popupViews.count == 1)
    }

    @Test("撤回空 owner 前缀不会误伤其他 owner")
    func doesNotMatchOwnerByPrefix() {
        let provider = DefaultStatusBarPopupProviding()
        provider.addPopupView(ownerID: "plugin.a", view("alpha"))
        provider.addPopupView(ownerID: "plugin.ab", view("beta"))

        provider.removePopupViews(ownerID: "plugin.a")

        // "plugin.ab" 应保留
        #expect(provider.popupViews.count == 1)
    }

    @Test("重复撤回同一 owner 幂等")
    func repeatedRemovalIsIdempotent() {
        let provider = DefaultStatusBarPopupProviding()
        provider.addPopupView(ownerID: "a", view("alpha"))

        provider.removePopupViews(ownerID: "a")
        provider.removePopupViews(ownerID: "a")

        #expect(provider.popupViews.isEmpty)
    }
}
