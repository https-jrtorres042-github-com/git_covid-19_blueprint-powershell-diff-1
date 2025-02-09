//
//  Decorate.swift
//  BlueprintUI
//
//  Created by Kyle Van Essen on 11/4/20.
//

import UIKit


///
/// Places a decoration element behind or in front of the given `wrapped` element,
/// and positions it according to the `position` parameter.
///
/// The size and position of the element is determined only by the `wrapped`
/// element, the `decoration` element does not affect the layout at all.
///
/// Example
/// -------
/// The arrows represent the measured size of the element for layout purposes.
/// ```
/// ┌───────────────────┐     ┌──────┐
/// │    Decoration     │     │      │
/// │ ┏━━━━━━━━━━━━━━━┓ │ ▲   │      ┣━━━━━━━━━━┓   ▲
/// │ ┃               ┃ │ │   └─┳────┘          ┃   │
/// │ ┃    Wrapped    ┃ │ │     ┃    Wrapped    ┃   │
/// │ ┃               ┃ │ │     ┃               ┃   │
/// │ ┗━━━━━━━━━━━━━━━┛ │ ▼     ┗━━━━━━━━━━━━━━━┛   ▼
/// └───────────────────┘
///   ◀───────────────▶         ◀───────────────▶
/// ```
public struct Decorate: ProxyElement {

    /// The element which provides the sizing and measurement.
    /// The sizing and position of the `Decorate` element is determined
    /// by this element.
    public var wrapped: Element

    /// The element which is used to draw the decoration.
    /// It does not affect sizing or positioning.
    public var decoration: Element

    /// Where the decoration should be positioned in the z-axis: Above or below the wrapped element.
    public var layering: Layering

    /// How the `decoration` should be positioned in respect to the `wrapped` element.
    public var position: Position

    /// Creates a new instance with the provided overflow, background, and wrapped element.
    public init(
        layering: Layering,
        position: Position,
        wrapping: Element,
        decoration: Element
    ) {
        self.layering = layering

        wrapped = wrapping

        self.position = position
        self.decoration = decoration
    }

    // MARK: ProxyElement

    public var elementRepresentation: Element {
        EnvironmentReader { environment in
            LayoutWriter { context, layout in

                let contentSize = self.wrapped.content.measure(
                    in: context.size,
                    environment: environment
                )

                let contentFrame = CGRect(origin: .zero, size: contentSize)

                let decorationFrame = self.position.frame(
                    with: contentFrame,
                    decoration: self.decoration,
                    environment: environment
                )

                layout.sizing = .fixed(contentSize)

                switch self.layering {
                case .above:
                    layout.add(with: contentFrame, child: self.wrapped)
                    layout.add(with: decorationFrame, child: self.decoration)

                case .below:
                    layout.add(with: decorationFrame, child: self.decoration)
                    layout.add(with: contentFrame, child: self.wrapped)
                }
            }
        }
    }
}


extension Decorate {

    /// If the decoration should be positioned above or below the content element.
    public enum Layering: Equatable {

        /// The decoration is displayed above the content element.
        case above

        /// The decoration is displayed below the content element.
        case below
    }

    /// What corner the decoration element should be positioned in.
    public enum Corner: Equatable {
        case topLeft
        case topRight
        case bottomRight
        case bottomLeft
    }

    /// How to position the decoration element relative to the content element.
    public enum Position {

        /// Insets the decoration element on each edge by the amount specified by
        /// the `UIEdgeInsets` property.
        ///
        /// A positive value for an edge expands the decoration outside of that edge,
        /// whereas a negative inset pushes the the decoration inside that edge.
        case inset(UIEdgeInsets)

        /// Provides a `.inset` position where the decoration is inset by the
        /// same amount on each side.
        public static func inset(_ amount: CGFloat) -> Self {
            .inset(UIEdgeInsets(top: amount, left: amount, bottom: amount, right: amount))
        }

        /// Provides a `.inset` position where the decoration is inset by the
        /// `horizontal` amount on the left and right, and the `vertical` amount on the top and bottom.
        public static func inset(horizontal: CGFloat = 0.0, vertical: CGFloat = 0.0) -> Self {
            .inset(UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal))
        }

        /// The decoration element is positioned in the given corner of the
        /// content element, optionally offset by the provided amount.
        case corner(Corner, UIOffset = .init())

        /// Allows you to provide custom positioning for the decoration, based on the passed context.
        case custom((CustomContext) -> CGRect)

        /// Information provided to the `.custom` positioning type.
        public struct CustomContext {

            /// The frame of the content element within the `Decorate` element.
            public var contentFrame: CGRect

            /// The environment the element is being rendered in.
            public var environment: Environment
        }

        func frame(
            with contentFrame: CGRect,
            decoration: Element,
            environment: Environment
        ) -> CGRect {

            switch self {
            case .inset(let inset):
                return contentFrame.inset(by: inset.negated)

            case .corner(let corner, let offset):

                let size = decoration.content.measure(in: .init(contentFrame.size), environment: environment)

                let center: CGPoint = {
                    switch corner {
                    case .topLeft:
                        return .zero
                    case .topRight:
                        return CGPoint(x: contentFrame.maxX, y: 0)
                    case .bottomRight:
                        return CGPoint(x: contentFrame.maxX, y: contentFrame.maxY)
                    case .bottomLeft:
                        return CGPoint(x: 0, y: contentFrame.maxY)
                    }
                }()

                return CGRect(
                    origin: CGPoint(
                        x: center.x - (size.width / 2.0),
                        y: center.y - (size.height / 2.0)
                    ),
                    size: size
                ).offset(
                    by: CGPoint(x: offset.horizontal, y: offset.vertical)
                )

            case .custom(let provider):
                return provider(.init(contentFrame: contentFrame, environment: environment))
            }
        }
    }
}


extension Element {

    /// Places a decoration element behind or in front of the given `wrapped` element,
    /// and positions it according to the `position` parameter.
    ///
    /// See the `Decorate` element for more.
    ///
    public func decorate(
        layering: Decorate.Layering,
        position: Decorate.Position,
        with decoration: () -> Element
    ) -> Element {

        Decorate(
            layering: layering,
            position: position,
            wrapping: self,
            decoration: decoration()
        )
    }
}


extension UIEdgeInsets {
    fileprivate var negated: UIEdgeInsets {
        UIEdgeInsets(
            top: -top,
            left: -left,
            bottom: -bottom,
            right: -right
        )
    }
}
