#if Repetition
public import Repetition
public import Cardinal
public import Either

extension Cardinal.Range {

    public func forEach<S: Iterable & ~Copyable & ~Escapable>(
        from source: borrowing S,
        _ yield: (borrowing S.Iterator.Element) -> Void
    ) throws(Either<Repetition<Self, Void>.Error, S.Iterator.Failure>) where S.Iterator.Element: ~Copyable {
        var iterator = source.makeIterator()
        guard contains(minimum) else { throw .left(.emptyBounds) }
        var count = Cardinal.zero
        while permitsAnother(after: count) {
            guard count.rawValue != UInt.max else { throw .left(.countOverflow) }
            do throws(S.Iterator.Failure) {
                let span = try iterator.next(maximumCount: Cardinal((maximum ?? Cardinal.max).rawValue - count.rawValue))
                if span.isEmpty { break }
                for index in span.indices { yield(span[index]) }
                count = Cardinal(count.rawValue + UInt(span.count))
            } catch { throw .right(error) }
        }
        guard contains(count) else {
            throw .left(.insufficient(actual: count))
        }
    }
}

#endif
