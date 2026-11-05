import KernelCore
import ProviderPoster
import SwiftUI
import Testing
@testable import PluginPosterHydration

@Suite("海报内容视图可创建性")
@MainActor
struct PosterContentCreatabilityTests {
    @Test("海报内容闭包可以构造出视图")
    func posterContentIsCreatable() throws {
        let kernel = KernelCoreContainer()
        let posters = DefaultPosterProviding()
        try kernel.registerProvider(PosterProviding.self, posters)

        try PluginPosterHydration().onBoot(kernel: kernel)

        let poster = try #require(posters.posters.first)
        let view = poster.content()
        #expect(type(of: view) == AnyView.self)
    }
}
