/// Represents a path into an element hierarchy.
/// Used for disambiguation during diff operations.
struct ElementPath: Hashable, CustomDebugStringConvertible {

    private var identifiersHash: Int? = nil

    private(set) var identifiers: [ElementIdentifier] = []

    private mutating func setIdentifiersHash() {
        var hasher = Hasher()
        hasher.combine(identifiers)

        identifiersHash = hasher.finalize()
    }

    mutating func prepend(identifier: ElementIdentifier) {
        identifiers.insert(identifier, at: 0)
        setIdentifiersHash()

    }

    mutating func append(identifier: ElementIdentifier) {
        identifiers.append(identifier)
        setIdentifiersHash()
    }

    func prepending(identifier: ElementIdentifier) -> ElementPath {
        var result = self
        result.prepend(identifier: identifier)
        return result
    }

    func appending(identifier: ElementIdentifier) -> ElementPath {
        var result = self
        result.append(identifier: identifier)
        return result
    }

    static var empty: ElementPath {
        return ElementPath()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifiersHash)
    }

    // MARK: CustomDebugStringConvertible

    var debugDescription: String {
        return identifiers.map { $0.debugDescription }.joined()
    }
}


