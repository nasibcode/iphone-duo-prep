import DuoHarnessTesting
import Testing

struct DuoHarnessTestingTests {
    @Test func presetsHaveDistinctPositiveSizes() {
        let sizes = DuoDisplayPreset.allCases.map(\.size)
        #expect(sizes.count == 3)
        #expect(Set(sizes.map { "\($0.width)x\($0.height)" }).count == 3)
        for size in sizes {
            #expect(size.width > 0)
            #expect(size.height > 0)
        }
        #expect(DuoDisplayPreset.duoOuterPortrait.size.width == 402)
        #expect(DuoDisplayPreset.duoInnerRegular.size.width == 740)
        #expect(DuoDisplayPreset.duoSplitHalf.size.width == 370)
    }
}
