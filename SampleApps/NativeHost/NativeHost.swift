import DuoHarness
import DuoHarnessTesting
import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(SwiftUI)
import SwiftUI
#endif

/// Dogfood host that links DuoHarness + DuoHarnessTesting (not an audit golden).
public enum NativeHost {
    public static let linkedPresets = DuoDisplayPreset.allCases

    public static func compactDemoWidth() -> CGFloat {
        DuoSizeGate.isCompactWidth(DuoDisplayPreset.duoOuterPortrait.size)
            ? DuoDisplayPreset.duoOuterPortrait.size.width
            : DuoDisplayPreset.duoInnerRegular.size.width
    }

    public static func demoInsets() -> DuoEdgeInsets {
        DuoSafeArea.insets(top: 47, left: 0, bottom: 34, right: 0)
    }
}

#if canImport(UIKit)
@MainActor
public final class HostViewController: UIViewController {
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let insets = DuoSafeArea.insets(from: view)
        let compact = DuoSizeGate.isCompactWidth(view.bounds.size)
        let scale = DuoScreen.displayScale(from: traitCollection)
        _ = (insets, compact, scale, DuoDisplayPreset.duoInnerRegular.size)
    }
}
#endif

#if canImport(SwiftUI)
public struct HostRootView: View {
    public init() {}

    public var body: some View {
        let size = DuoDisplayPreset.duoSplitHalf.size
        let compact = DuoSizeGate.isCompactWidth(size) ? "yes" : "no"
        Text("w=\(Int(size.width)) compact=\(compact)")
            .padding(
                EdgeInsets(
                    top: NativeHost.demoInsets().top,
                    leading: NativeHost.demoInsets().left,
                    bottom: NativeHost.demoInsets().bottom,
                    trailing: NativeHost.demoInsets().right
                )
            )
    }
}
#endif
