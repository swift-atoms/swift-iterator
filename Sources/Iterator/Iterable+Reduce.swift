public import Cardinal

extension Iterable where Self: ~Copyable & ~Escapable, Iterator.Failure == Never {

    @inlinable
    public borrowing func reduce<Result: ~Copyable, E: Swift.Error>(
        into initial: consuming Result,
        _ accumulate: (inout Result, borrowing Iterator.Element) throws(E) -> Void
    ) throws(E) -> Result {
        var result = initial
        var iterator = makeIterator()
        while true {
            let span = iterator.next(maximumCount: Cardinal(UInt.max))
            if span.isEmpty { break }
            for i in span.indices {
                try accumulate(&result, span[i])
            }
        }
        return result
    }
}
