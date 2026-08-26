public import Cardinal
public import Either
public import Iterator_Chunk

extension Iterable where Self: ~Copyable & ~Escapable, Iterator.Failure == Never {

    @inlinable
    public borrowing func forEach<E: Swift.Error>(
        _ body: (borrowing Iterator.Element) throws(E) -> Void
    ) throws(E) {
        var iterator = makeIterator()
        while true {
            let span = iterator.next(maximumCount: Cardinal(UInt.max))
            if span.isEmpty { break }
            for i in span.indices {
                try body(span[i])
            }
        }
    }
}

extension Iterable where Self: ~Copyable & ~Escapable {

    @inlinable
    public borrowing func forEach<E: Swift.Error>(
        _ body: (borrowing Iterator.Element) throws(E) -> Void
    ) throws(Either<E, Iterator.Failure>) {
        var iterator = makeIterator()
        while true {
            let span: Swift.Span<Iterator.Element>
            do throws(Iterator.Failure) {
                span = try iterator.next(maximumCount: Cardinal(UInt.max))
            } catch {
                throw Either.right(error)
            }
            if span.isEmpty { return }
            for i in span.indices {
                do throws(E) {
                    try body(span[i])
                } catch {
                    throw Either.left(error)
                }
            }
        }
    }
}
