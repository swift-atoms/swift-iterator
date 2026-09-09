extension Iterable where Self: ~Copyable & ~Escapable, Iterator.Element: Copyable & Escapable {
    /// Borrows the iterable, obtaining exactly one chunk iterator.
    @_lifetime(borrow self)
    public borrowing func bufferedIterator() -> Iterator::Iterator.Buffered<Iterator::Iterator.Flattened<Self.Iterator>, Self.Iterator.Failure> {
        Iterator::Iterator.Buffered(Iterator::Iterator.Flattened(makeIterator()))
    }
}
