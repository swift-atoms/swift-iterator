extension Iterator {
    public struct Standard<Wrapped: Swift.IteratorProtocol>: Iterating {
        public var wrapped: Wrapped
        public init(_ wrapped: Wrapped) { self.wrapped = wrapped }
        public mutating func next() -> Wrapped.Element? { wrapped.next() }
    }
}
