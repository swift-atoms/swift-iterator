#if Prefix
public import Prefix
public import Either

extension Prefix.Through {


    public func forEach<I: Iterating & ~Copyable & ~Escapable>(
        in input: inout Prefix.Iterator<I, I.Failure>,
        _ yield: (Delimiter.Element) -> Void
    ) throws(Either<Error, I.Failure>) where I.Element == Delimiter.Element {
        try Prefix.UpTo(delimiter).scan(in: &input, includingDelimiter: true, yield)
    }
}

#endif
