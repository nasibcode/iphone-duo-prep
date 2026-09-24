import iPhoneDuoPrepTesting
import Testing

// Phase A2 presets; Phase A6 matrix.
struct iPhoneDuoPrepTestingTests {
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

    @Test func uiTestMatrixCoversAllPresets() {
        #expect(DuoUITestMatrix.entries.count == DuoDisplayPreset.allCases.count)
        #expect(DuoUITestMatrix.argumentLines().count == 3)
        let table = DuoUITestMatrix.markdownTable()
        #expect(table.contains("duoOuterPortrait"))
        #expect(table.contains("duoInnerRegular"))
        #expect(table.contains("duoSplitHalf"))
    }
}
