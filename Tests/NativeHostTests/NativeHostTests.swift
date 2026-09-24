import NativeHost
import Testing

struct NativeHostTests {
    @Test func linksPresetsAndHelpers() {
        #expect(NativeHost.linkedPresets.count == 3)
        #expect(NativeHost.compactDemoWidth() == 402)
        let insets = NativeHost.demoInsets()
        #expect(insets.top == 47)
        #expect(insets.bottom == 34)
        let chrome = NativeHost.foldSafeChromeInsets()
        #expect(chrome.top == 0)
        let (arrangement, outer) = NativeHost.arrangementOuterDemo()
        #expect(arrangement.primary.width == 370)
        #expect(!outer)
    }
}
