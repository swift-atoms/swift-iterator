#if Prefix
public import Prefix
public import Either

extension Prefix.UpTo where Delimiter: Swift.Collection, Delimiter.Element: Equatable {


    public func forEach<I: Iterating & ~Copyable & ~Escapable>(
        in input: inout Prefix.Iterator<I, I.Failure>,
        _ yield: (Delimiter.Element) -> Void
    ) throws(Either<Error, I.Failure>) where I.Element == Delimiter.Element {
        try scan(in: &input, includingDelimiter: false, yield)
    }

    func scan<I: Iterating & ~Copyable & ~Escapable>(
        in input: inout Prefix.Iterator<I, I.Failure>,
        includingDelimiter: Bool,
        _ yield: (Delimiter.Element) -> Void
    ) throws(Either<Error, I.Failure>) where I.Element == Delimiter.Element {
        let pattern = Array(delimiter)
        if pattern.isEmpty { return }
        var candidate: [Delimiter.Element] = []
        while true {
            while candidate.count < pattern.count {
                let next: Delimiter.Element?
                do throws(I.Failure) {
                    next = try input.next()
                } catch {
                    for element in candidate.reversed() { input.unread(element) }
                    throw .right(error)
                }
                guard let next else {
                    for element in candidate.reversed() { input.unread(element) }
                    throw .left(.delimiterNotFound)
                }
                candidate.append(next)
            }
            if candidate == pattern {
                if includingDelimiter {
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
