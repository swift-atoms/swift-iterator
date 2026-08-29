public import Cardinal
public import Cardinal_Carrier
public import Either
public import Iterator_Chunk

extension Iterable where Self: ~Copyable & ~Escapable, Iterator.Failure == Never {

    @inlinable
    public borrowing func contains<E: Swift.Error>(
        where predicate: (borrowing Iterator.Element) throws(E) -> Bool
    ) throws(E) -> Bool {
        var iterator = makeIterator()
        while true {
            let span = iterator.next(maximumCount: Cardinal(UInt.max))
            if span.isEmpty { break }
            for i in span.indices {
                if try predicate(span[i]) { return true }
            }
        }
        return false
    }
}

extension Iterable where Self: ~Copyable & ~Escapable {

    @inlinable
    public borrowing func contains<E: Swift.Error>(
        where predicate: (borrowing Iterator.Element) throws(E) -> Bool
    ) throws(Either<E, Iterator.Failure>) -> Bool {
        var iterator = makeIterator()
        while true {
            let span: Swift.Span<Iterator.Element>
            do throws(Iterator.Failure) {
                span = try iterator.next(maximumCount: Cardinal(UInt.max))
            } catch { throw Either.right(error) }
            if span.isEmpty { return false }
            for i in span.indices {
                do throws(E) {
                    if try predicate(span[i]) { return true }
                } catch {
                    throw Either.left(error)
                }
            }
        }
    }
}
