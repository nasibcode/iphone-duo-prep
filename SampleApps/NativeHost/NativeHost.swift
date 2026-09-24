// Phase A2/A3/A4 — dogfood host linking iPhoneDuoPrep + Testing.
import iPhoneDuoPrep
import iPhoneDuoPrepTesting
import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(SwiftUI)
import SwiftUI
#endif

/// Dogfood host that links iPhoneDuoPrep + iPhoneDuoPrepTesting (not an audit golden).
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

    /// Fold-safe chrome path — reserved insets are zero until DuoFeatureGate flips.
    public static func foldSafeChromeInsets() -> DuoEdgeInsets {
        DuoReservedRegion.insets()
    }

    /// Optional Arrangement + outer-display path (outer activation is false while unavailable).
    public static func arrangementOuterDemo() -> (DuoArrangement, Bool) {
        let arrangement = DuoArrangement.splitHalf(container: DuoDisplayPreset.duoInnerRegular.size)
        return (arrangement, DuoSceneSession.activateOuterIfAvailable())
    }

    /// Opt-in camera/outer scaffold path (always false until DuoFeatureGate flips).
    public static func cameraOuterScaffoldDemo() -> (Bool, Bool) {
        (DuoCameraDirection.facingUserForCurrentUI, DuoOuterAccessory.registerPreviewAccessoryIfAvailable())
    }
}

#if canImport(UIKit)
@MainActor
public final class HostViewController: UIViewController {
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let insets = DuoSafeArea.insets(from: view)
        let reserved = DuoReservedRegion.layoutGuideInsets(for: view)
        let compact = DuoSizeGate.isCompactWidth(view.bounds.size)
        let scale = DuoScreen.displayScale(from: traitCollection)
        let arrangement = DuoArrangement.splitHalf(container: view.bounds.size)
        let outer = DuoSceneSession.activateOuterIfAvailable()
        _ = (insets, reserved, compact, scale, arrangement, outer, DuoDisplayPreset.duoInnerRegular.size)
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
