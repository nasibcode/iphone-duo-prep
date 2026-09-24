import CoreGraphics
import DuoHarness
import Testing

struct DuoHarnessTests {
    @Test func safeAreaKeepsEdgesSeparate() {
        let insets = DuoSafeArea.insets(top: 47, left: 0, bottom: 34, right: 0)
        #expect(insets.top == 47)
        #expect(insets.bottom == 34)
        #expect(insets.top + insets.bottom == 81)
    }

    @Test func sizeGateUsesContainerWidth() {
        #expect(DuoSizeGate.isCompactWidth(CGSize(width: 402, height: 874)))
        #expect(!DuoSizeGate.isCompactWidth(CGSize(width: 740, height: 1024)))
    }

    @Test func displayScalePassthrough() {
        #expect(DuoScreen.displayScale(from: 3) == 3)
    }

    @Test func differentiatedAPIsUnavailableWithoutHardFail() {
        #expect(!DuoFeatureGate.differentiatedAPIsAvailable)
        let reserved = DuoReservedRegion.insets(top: 10, left: 1, bottom: 10, right: 1)
        #expect(reserved == DuoEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        #expect(DuoHinge.currentFraction == 0)
        let token = DuoHinge.observe { _ in }
        DuoHinge.cancel(token)
        let arrangement = DuoArrangement.splitHalf(container: CGSize(width: 740, height: 1024))
        #expect(arrangement.primary.width == 370)
        #expect(!arrangement.isAvailable)
        #expect(!DuoSceneSession.activateOuterIfAvailable())
    }
}
