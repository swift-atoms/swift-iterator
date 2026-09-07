public import Cardinal
public import Carrier
public import Iterator
public import Iterator_Protocol

extension Iterator {

    public struct Materializing<Source: Iterator.`Protocol` & ~Copyable & ~Escapable>:
        __IteratorChunkProtocol, ~Copyable, ~Escapable
    where Source.Element: Copyable & Escapable {
        @usableFromInline var source: Source
        @usableFromInline var slot: [Source.Element]

        @inlinable
        @_lifetime(copy source)
        public init(_ source: consuming Source) {
            self.source = source
            self.slot = []
        }
    }
}

extension Iterator.Materializing
where Source: ~Copyable & ~Escapable, Source.Element: Copyable & Escapable {

    public typealias Element = Source.Element

    public typealias Failure = Source.Failure

    @inlinable
    @_lifetime(&self)
    public mutating func next(
        maximumCount: some Carrier.`Protocol`<Cardinal>
    ) throws(Source.Failure) -> Swift.Span<Source.Element> {
        if let value = try source.next() {
            if slot.isEmpty { slot.append(value) } else { slot[0] = value }
            return slot.span.extracting(first: 1)
        }
        return slot.span.extracting(first: 0)
    }
}
