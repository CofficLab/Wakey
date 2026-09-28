import FactoryWakey
import ProviderTheme
import Testing

@MainActor
struct FactoryWakeyTests {
    @Test("Wakey uses the canonical remote theme catalog")
    func remoteThemeCatalogHasCanonicalCount() throws {
        let kernel = try FactoryWakey.makeKernel()
        let theme = try #require(kernel.resolveProvider((any ThemeProviding).self))

        #expect(theme.themes.count == 22)
        #expect(Set(theme.themes.map(\.id)).count == 22)
    }
}
