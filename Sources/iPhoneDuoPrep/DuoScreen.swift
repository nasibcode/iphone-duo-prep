// Phase A2 — screen / scale shims.
import CoreGraphics

#if canImport(UIKit)
import UIKit
#endif

public enum DuoScreen {
    public static func displayScale(from scale: CGFloat) -> CGFloat { scale }

    #if canImport(UIKit)
    public static func displayScale(from traits: UITraitCollection) -> CGFloat {
        traits.displayScale
    }

    public static func screen(forWindowScene scene: UIWindowScene) -> UIScreen {
        scene.screen
    }

    public static func screen(for view: UIView) -> UIScreen? {
        view.window?.windowScene.map(screen(forWindowScene:))
    }
    #endif
}
