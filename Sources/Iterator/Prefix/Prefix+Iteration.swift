#if Prefix
public import Prefix
internal import Predicate
public import Either

extension Prefix {
    /// Delivers selected elements once. Partial delivery is retained on failure.
    public func forEach<I: Iterating & ~Copyable & ~Escapable>(
        in input: inout I,
        _ yield: (consuming I.Element) -> Void
    ) throws(Either<Error, I.Failure>)
    where I.Element: ~Copyable & ~Escapable {
        var count = 0
        while count < maximum {
            do throws(I.Failure) {
                guard let element = try input.next() else { break }
                yield(element)
                count += 1
            } catch { throw .right(error) }
        }
        guard count >= minimum else {
            throw .left(.insufficientElements(minimum: minimum, actual: count))
        }
    }
}

extension Prefix.While where Element: ~Copyable & Escapable {
    /// Retains the first rejected element in the input wrapper.
    public func forEach<I: Iterating & ~Copyable & ~Escapable>(
        in input: inout Prefix.Iterator<I, I.Failure>,
        _ yield: (consuming Element) -> Void
    ) throws(Either<Prefix.Error, I.Failure>) where I.Element == Element, I.Element: ~Copyable & Escapable {
        var count = 0
        while count < bounds.maximum {
            do throws(I.Failure) {
                guard let element = try input.next() else { break }
                guard predicate(element) else {
                    input.unread(element)
                    break
                }
                yield(element)
                count += 1
            } catch { throw .right(error) }
        }
        guard count >= bounds.minimum else {
            throw .left(.insufficientElements(minimum: bounds.minimum, actual: count))
        }
    }
}

#endif
