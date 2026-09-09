#if Prefix
public import Prefix
internal import Predicate
internal import Cardinal
public import Either

extension Iterable where Self: ~Copyable & ~Escapable, Iterator.Element: Copyable & Escapable {
    /// Borrows the iterable, obtaining exactly one chunk iterator.
    @_lifetime(borrow self)
    public borrowing func prefixIterator() -> Prefix.Iterator<Prefix.Chunk<Self.Iterator>, Self.Iterator.Failure> {
        Prefix.Iterator(Prefix.Chunk(makeIterator()))
    }
}

extension Prefix {
    /// Borrows elements directly from their chunks; no element is copied or retained.
    public func forEach<S: Iterable & ~Copyable & ~Escapable>(
        from source: borrowing S,
        _ yield: (borrowing S.Iterator.Element) -> Void
    ) throws(Either<Error, S.Iterator.Failure>) where S.Iterator.Element: ~Copyable {
        var iterator = source.makeIterator()
        var count = 0
        while count < maximum {
            do throws(S.Iterator.Failure) {
                let span = try iterator.next(maximumCount: Cardinal(UInt(maximum - count)))
                if span.isEmpty { break }
                for index in span.indices { yield(span[index]) }
                count += span.count
            } catch { throw .right(error) }
        }
        guard count >= minimum else {
            throw .left(.insufficientElements(minimum: minimum, actual: count))
        }
    }
}

#endif
