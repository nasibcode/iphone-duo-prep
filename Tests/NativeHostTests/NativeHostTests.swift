import NativeHost
import Testing

struct NativeHostTests {
    @Test func linksPresetsAndHelpers() {
        #expect(NativeHost.linkedPresets.count == 3)
        #expect(NativeHost.compactDemoWidth() == 402)
        let insets = NativeHost.demoInsets()
        #expect(insets.top == 47)
        #expect(insets.bottom == 34)
    }
}
