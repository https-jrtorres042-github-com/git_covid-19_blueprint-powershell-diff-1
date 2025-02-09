import CoreGraphics

extension CGRect {
    init(minX: CGFloat, minY: CGFloat, maxX: CGFloat, maxY: CGFloat) {
        self.init(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )
    }

    /// Creates a new rectangle by rounding each of the min and max X and Y values of this rect individually.
    /// - Parameters:
    ///   - rule: The rounding rule.
    ///   - scale: The rounding scale.
    /// - Returns: A rectangle with the rounded values.
    func rounded(_ rule: FloatingPointRoundingRule, by scale: CGFloat) -> CGRect {
        return CGRect(
            minX: minX.rounded(rule, by: scale),
            minY: minY.rounded(rule, by: scale),
            maxX: maxX.rounded(rule, by: scale),
            maxY: maxY.rounded(rule, by: scale)
        )
    }

    func offset(by point: CGPoint) -> CGRect {
        return offsetBy(dx: point.x, dy: point.y)
    }
}
