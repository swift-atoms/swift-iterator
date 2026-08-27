public import Cardinal

extension Iterator {

    public struct Chunk<Element: ~Copyable>: ~Copyable, ~Escapable {
        @usableFromInline let span: Swift.Span<Element>
        @usableFromInline let count: Int
        @usableFromInline var position: Int

        @inlinable
        @_lifetime(copy span)
        public init(_ span: Swift.Span<Element>) {
            self.span = span
            self.count = span.count
            self.position = 0
        }
    }
}

extension Iterator.Chunk: __IteratorChunkProtocol where Element: ~Copyable {

    public typealias Failure = Never

    @inlinable
    @_lifetime(&self)
    public mutating func next(
        maximumCount: Cardinal
    ) -> Swift.Span<Element> {
        let remaining = count - position
        let requested = Int(clamping: maximumCount.rawValue)
        let take = Swift.min(requested, remaining)
        guard take > 0 else { return span.extracting(first: 0) }
        let result = span.extracting(droppingFirst: position).extracting(first: take)
        position += take
        return result
    }
}
