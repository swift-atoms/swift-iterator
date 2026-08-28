extension Iterator {

    public protocol `Protocol`<Element, Failure>: ~Copyable, ~Escapable {

        associatedtype Element: ~Copyable & ~Escapable

        associatedtype Failure: Swift.Error = Never

        @_lifetime(&self)
        mutating func next() throws(Failure) -> Element?
    }
}
