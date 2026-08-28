extension Iterator.Chunk {

    public typealias `Protocol` = __IteratorChunkProtocol
}

extension Iterator.Chunk.`Protocol` where Self: ~Copyable & ~Escapable, Element: Copyable {

    @inlinable
    public mutating func next() throws(Failure) -> Element? {
        let span = try next(maximumCount: Cardinal.one)
        return span.isEmpty ? nil : span[0]
    }
}
