extension Iterator {

    public struct Witness<Element, Failure: Swift.Error>: Iterator.`Protocol`, ~Copyable {
        @usableFromInline
        internal var _next: () throws(Failure) -> Element?

        @inlinable
        public init(_ next: @escaping () throws(Failure) -> Element?) {
            self._next = next
        }
    }
}

extension Iterator.Witness {

    @inlinable
    public mutating func next() throws(Failure) -> Element? {
        try _next()
    }
}

extension Iterator.Witness {

    @inlinable
    public init<Source: Iterator.`Protocol`>(_ source: Source)
    where Source.Element == Element, Source.Failure == Failure {
        var local = source
        self.init { () throws(Failure) -> Element? in
            try local.next()
        }
    }
}
