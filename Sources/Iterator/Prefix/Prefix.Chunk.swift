#if Prefix
public import Prefix

extension Prefix {
    /// Materializes one owned element from a borrowed chunk at a time.
    public struct Chunk<Source: __IteratorChunkProtocol & ~Copyable & ~Escapable>: Iterating, ~Copyable, ~Escapable
    where Source.Element: Copyable & Escapable {
        private var source: Source
        @_lifetime(copy source)
        public init(_ source: consuming Source) { self.source = source }
        public mutating func next() throws(Source.Failure) -> Source.Element? {
            try source.next()
        }
    }
}

#endif
