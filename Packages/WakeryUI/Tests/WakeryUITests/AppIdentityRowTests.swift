import Testing
@testable import WakeryUI

struct AppIdentityRowTests {
    @Test
    @MainActor
    func filtersBlankMetadataEntries() {
        let row = AppIdentityRow(title: "Wakey", metadata: ["gpt-5.4", "", "  ", "openai"])

        #expect(row.metadata == ["gpt-5.4", "openai"])
    }
}
