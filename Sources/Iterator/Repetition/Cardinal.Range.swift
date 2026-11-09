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
            guard bounds != .empty else { throw .left(.emptyBounds) }
            let maximum: Cardinal =
                switch bounds {
                case .bounded(_, let maximum): maximum
                case .empty, .unbounded: .max
                }
            var count = Cardinal.zero
            while permitsAnother(after: count) {
                guard count.rawValue != UInt.max else { throw .left(.countOverflow) }
                do throws(S.Iterator.Failure) {
                    let span = try iterator.next(maximumCount: Cardinal(maximum.rawValue - count.rawValue))
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

#if Repetition
    public import Repetition
    public import Cardinal
    internal import Predicate
    public import Either

    extension Cardinal.Range {

        public func forEach<I: Iterating & ~Copyable & ~Escapable>(
            in input: inout I,
            _ yield: (consuming I.Element) -> Void
        ) throws(Either<Repetition<Self, Void>.Error, I.Failure>)
        where I.Element: ~Copyable & ~Escapable {
            guard bounds != .empty else { throw .left(.emptyBounds) }
            var count = Cardinal.zero
            while permitsAnother(after: count) {
                guard count.rawValue != UInt.max else { throw .left(.countOverflow) }
                do throws(I.Failure) {
                    guard let element = try input.next() else { break }
                    yield(element)
                    count = Cardinal(count.rawValue + 1)
                } catch { throw .right(error) }
            }
            guard contains(count) else {
                throw .left(.insufficient(actual: count))
            }
        }
    }

#endif
