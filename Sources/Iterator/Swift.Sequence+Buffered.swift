extension Swift.Sequence {

    public consuming func bufferedIterator() -> Iterator::Iterator.Buffered<Iterator::Iterator.Standard<Self.Iterator>, Never> {
        Iterator::Iterator.Buffered(Iterator::Iterator.Standard(makeIterator()))
    }
}
