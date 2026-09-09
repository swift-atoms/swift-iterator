#if Search
public import Search
public import Either

extension Search.Selection where Pattern: Swift.Collection, Pattern.Element: Equatable {


    public func forEach<I: Iterating & ~Copyable & ~Escapable>(
        in input: inout Iterator::Iterator.Buffered<I, I.Failure>,
        _ yield: (Pattern.Element) -> Void
    ) throws(Either<Error, I.Failure>) where I.Element == Pattern.Element {
        try scan(in: &input, yield)
    }

    func scan<I: Iterating & ~Copyable & ~Escapable>(
        in input: inout Iterator::Iterator.Buffered<I, I.Failure>,
        _ yield: (Pattern.Element) -> Void
    ) throws(Either<Error, I.Failure>) where I.Element == Pattern.Element {
        let pattern = Array(delimiter)
        if pattern.isEmpty { return }
        var candidate: [Pattern.Element] = []
        while true {
            while candidate.count < pattern.count {
                let next: Pattern.Element?
                do throws(I.Failure) {
                    next = try input.next()
                } catch {
                    for element in candidate.reversed() { input.unread(element) }
                    throw .right(error)
                }
                guard let next else {
                    for element in candidate.reversed() { input.unread(element) }
                    throw .left(.notFound)
                }
                candidate.append(next)
            }
            if candidate == pattern {
                if boundary == .end {
                    for element in candidate { yield(element) }
                } else {
                    for element in candidate.reversed() { input.unread(element) }
                }
                return
            }
            yield(candidate.removeFirst())
        }
    }
}

#endif
