extension Swift.Sequence {
    /// Creates exactly one iterator and retains it together with prefix lookahead.
    public consuming func bufferedIterator() -> Iterator::Iterator.Buffered<Iterator::Iterator.Standard<Self.Iterator>, Never> {
        Iterator::Iterator.Buffered(Iterator::Iterator.Standard(makeIterator()))
    }
}
