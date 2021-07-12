/// Centers a content element within itself.
///
/// The size of the content element is determined by calling `measure(in:)` on
/// the content element – even if that size is larger than the wrapping `Centered`
/// element.
///
public struct Centered : ProxyElement, ComparableElement {

    /// The content element to be centered.
    public var wrapped: Element

    /// Initializes a `Centered` element with the given content element.
    public init(_ wrapped: Element) {
        self.wrapped = wrapped
    }

    public var elementRepresentation: Element {
        Aligned(
            vertically: .center,
            horizontally: .center,
            wrapping: wrapped
        )
    }
    
    private static let isEquivalent = IsEquivalent<Centered> {
        $0.add(\.wrapped)
    }
    
    public func isEquivalent(to other: Centered) throws -> Bool {
        try Self.isEquivalent.compare(self, other)
    }
}


public extension Element {
    
    /// Wraps the element in a `Centered` element to center it within its parent.
    func centered() -> Centered {
        Centered(self)
    }
}
