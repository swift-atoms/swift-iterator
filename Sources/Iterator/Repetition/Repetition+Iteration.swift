#if Repetition
public import Repetition
public import Cardinal
public import Predicate
public import Either

extension Repetition where Bounds: Cardinal.Range {
    public func forEach<I: Iterating & ~Copyable & ~Escapable>(
        in input: inout Iterator.Buffered<I, I.Failure>,
        _ yield: (consuming I.Element) -> Void
    ) throws(Either<Repetition<Bounds, Void>.Error, I.Failure>)
    where I.Element: ~Copyable & Escapable, Operation == Predicate<I.Element> {
        guard bounds.contains(bounds.minimum) else { throw .left(.emptyBounds) }
        var count = Cardinal.zero
        while bounds.permitsAnother(after: count) {
            guard count.rawValue != UInt.max else { throw .left(.countOverflow) }
            do throws(I.Failure) {
                guard let element = try input.next() else { break }
                guard operation(element) else { input.unread(element); break }
                yield(element)
                count = Cardinal(count.rawValue + 1)
            } catch { throw .right(error) }
        }
        guard bounds.contains(count) else { throw .left(.insufficient(actual: count)) }
    }
}
#endif
