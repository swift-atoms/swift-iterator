public import Cardinal
public import Cardinal_Carrier
public import Iterator

extension Iterator.Chunk {

    public typealias `Protocol` = __IteratorChunkProtocol
}

extension Iterator.Chunk.`Protocol` where Self: ~Copyable & ~Escapable, Element: Copyable {

    @inlinable
    public mutating func next() throws(Failure) -> Element? {
        let span = try next(maximumCount: Cardinal(1))
        return span.isEmpty ? nil : span[0]
    }
}
