public import Cardinal
public import Either
public import Iterator_Chunk

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

extension Iterable
where Self: ~Copyable & ~Escapable, Iterator.Element: Copyable & Escapable {

    @inlinable
    public borrowing func first<E: Swift.Error>(
        where predicate: (borrowing Iterator.Element) throws(E) -> Bool
    ) throws(Either<E, Iterator.Failure>) -> Iterator.Element? {
        var iterator = makeIterator()
        while true {
            let span: Swift.Span<Iterator.Element>
            do throws(Iterator.Failure) {
                span = try iterator.next(maximumCount: Cardinal(UInt.max))
            } catch { throw Either.right(error) }
            if span.isEmpty { return nil }
            for i in span.indices {
                let element = span[i]
                do throws(E) {
                    if try predicate(element) { return element }
                } catch {
                    throw Either.left(error)
                }
            }
        }
    }
}
