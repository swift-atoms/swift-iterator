extension Iterator {

    public enum Once<Element: ~Copyable & ~Escapable>: Iterator.`Protocol`, ~Copyable, ~Escapable {

        case pending(Element)

        case done

        @inlinable
        @_lifetime(copy element)
        public init(_ element: consuming Element) {
            self = .pending(element)
        }
    }
}

extension Iterator.Once where Element: ~Copyable & ~Escapable {

    public typealias Failure = Never

    @inlinable
    @_lifetime(&self)
    public mutating func next() -> Element? {
        switch consume self {
        case .pending(let element):
            self = .done
            return element

        case .done:
            self = .done
            return nil
        }
    }
}
