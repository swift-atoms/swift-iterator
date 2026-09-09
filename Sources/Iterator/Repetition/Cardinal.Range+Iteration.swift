#if Repetition
public import Repetition
public import Cardinal
internal import Predicate
public import Either

extension Cardinal.Range {
    /// Delivers selected elements once. Partial delivery is retained on failure.
    public func forEach<I: Iterating & ~Copyable & ~Escapable>(
        in input: inout I,
        _ yield: (consuming I.Element) -> Void
    ) throws(Either<Repetition<Self, Void>.Error, I.Failure>)
    where I.Element: ~Copyable & ~Escapable {
        guard contains(minimum) else { throw .left(.emptyBounds) }
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
