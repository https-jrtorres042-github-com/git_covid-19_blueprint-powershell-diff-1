import BlueprintUI
import UIKit

public struct AttributedLabel: Equatable, EquatableElement {

    public var attributedText: NSAttributedString
    public var numberOfLines: Int = 0
    public var isAccessibilityElement = false

    /// An offset that will be applied to the rect used by `drawText(in:)`.
    ///
    /// This can be used to adjust the positioning of text within each line's frame, such as adjusting
    /// the way text is distributed within the line height.
    public var textRectOffset: UIOffset = .zero

    public init(attributedText: NSAttributedString, configure : (inout Self) -> () = { _ in }) {
        self.attributedText = attributedText
        
        configure(&self)
    }

    private static let measurementLabel = LabelView()
    
    public var content: ElementContent {
        ElementContent { constraint, context -> CGSize in
            self.update(label: Self.measurementLabel)
            return Self.measurementLabel.sizeThatFits(constraint.maximum)
        }
    }

    private func update(label: LabelView) {
        label.attributedText = attributedText
        label.numberOfLines = numberOfLines
        label.isAccessibilityElement = isAccessibilityElement
        label.textRectOffset = textRectOffset
    }

    public func backingViewDescription(with context: ViewDescriptionContext) -> ViewDescription? {
        return LabelView.describe { (config) in
            config.apply(update)
        }
    }
}

extension AttributedLabel {
    private final class LabelView: UILabel {
        var textRectOffset: UIOffset = .zero {
            didSet {
                if oldValue != textRectOffset {
                    setNeedsDisplay()
                }
            }
        }

        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.offsetBy(dx: textRectOffset.horizontal, dy: textRectOffset.vertical))
        }
    }
}

