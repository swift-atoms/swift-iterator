public import Cardinal

extension Iterable
where
    Self: ~Copyable & ~Escapable,
    Iterator.Failure == Never,
    Iterator.Element: Copyable & Escapable
{

    @inlinable
    public borrowing func first<E: Swift.Error>(
        where predicate: (borrowing Iterator.Element) throws(E) -> Bool
    ) throws(E) -> Iterator.Element? {
        var iterator = makeIterator()
        while true {
            let span = iterator.next(maximumCount: Cardinal(UInt.max))
            if span.isEmpty { break }
            for i in span.indices {
                let element = span[i]
                if try predicate(element) { return element }
            }
        }
        return nil
    }
}
