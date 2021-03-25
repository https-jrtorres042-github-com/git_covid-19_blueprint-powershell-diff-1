import BlueprintUI
import UIKit


/// Blocks all accessibility on the element, so that it is
/// is no longer an accessibility element, and its children are
/// hidden from the accessibility system.
public struct AccessibilityBlocker: Element {

    public var wrapped: Element

    /// Creates a new `AccessibilityBlocker` wrapping the provided element.
    public init(wrapping element: Element) {
        self.wrapped = element
    }
    
    //
    // MARK: Element
    //

    public var content: ElementContent {
        wrapped.content
    }

    public func backingViewDescription(bounds: CGRect, subtreeExtent: CGRect?) -> ViewDescription? {
        return UIView.describe { config in
            config[\.isAccessibilityElement] = false
            config[\.accessibilityElementsHidden] = true
        }
    }
}


public extension Element {
    
    /// Blocks all accessibility on the element, so that it is
    /// is no longer an accessibility element, and its children are
    /// hidden from the accessibility system.
    func blockAccessibility() -> AccessibilityBlocker {
        AccessibilityBlocker(wrapping: self)
    }
}
