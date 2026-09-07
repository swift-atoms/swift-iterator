public import Cardinal
public import Either

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

extension Iterable where Self: ~Copyable & ~Escapable {

    @inlinable
    public borrowing func reduce<Result: ~Copyable, E: Swift.Error>(
        into initial: consuming Result,
        _ accumulate: (inout Result, borrowing Iterator.Element) throws(E) -> Void
    ) throws(Either<E, Iterator.Failure>) -> Result {
        var result = initial
        var iterator = makeIterator()
        while true {
            let span: Swift.Span<Iterator.Element>
            do throws(Iterator.Failure) {
                span = try iterator.next(maximumCount: Cardinal(UInt.max))
            } catch { throw Either.right(error) }
            if span.isEmpty { return result }
            for i in span.indices {
                do throws(E) {
                    try accumulate(&result, span[i])
                } catch {
                    throw Either.left(error)
                }
            }
        }
    }
}
