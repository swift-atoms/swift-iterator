public protocol Iterable: ~Copyable, ~Escapable {

    associatedtype Iterator: __IteratorChunkProtocol, ~Copyable, ~Escapable
    where Iterator.Element: ~Copyable

    @_lifetime(borrow self)
    borrowing func makeIterator() -> Iterator
}
