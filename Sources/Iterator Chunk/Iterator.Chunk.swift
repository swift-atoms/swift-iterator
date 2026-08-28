public import Cardinal
public import Cardinal_Add
public import Cardinal_Subtract
public import Cardinal_Standard_Library_Integration
public import Carrier_Protocol
public import Iterator

extension Iterator {

    public struct Chunk<Element: ~Copyable>: ~Copyable, ~Escapable {
        @usableFromInline let span: Swift.Span<Element>
        @usableFromInline let count: Cardinal
        @usableFromInline var position: Cardinal

        @inlinable
        @_lifetime(copy span)
        public init(_ span: Swift.Span<Element>) {
            self.span = span
            self.count = Cardinal(UInt(bitPattern: span.count))
            self.position = .zero
        }
    }
}

extension Iterator.Chunk: __IteratorChunkProtocol where Element: ~Copyable {

    public typealias Failure = Never

    @inlinable
    @_lifetime(&self)
    public mutating func next(
        maximumCount: some Carrier.`Protocol`<Cardinal>
    ) -> Swift.Span<Element> {
        let remaining = count.subtract.saturating(position)
        let take = Swift.min(maximumCount.underlying, remaining)
        guard take > .zero else { return span.extracting(first: Cardinal.zero) }
        let result = span.extracting(droppingFirst: position).extracting(first: take)
        position = position.add.saturating(take)
        return result
    }
}
