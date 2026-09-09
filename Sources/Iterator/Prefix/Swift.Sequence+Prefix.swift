#if Prefix
public import Prefix
extension Swift.Sequence {
    /// Creates exactly one iterator and retains it together with prefix lookahead.
    public consuming func prefixIterator() -> Prefix.Iterator<Prefix.Iteration<Self.Iterator>, Never> {
        Prefix.Iterator(Prefix.Iteration(makeIterator()))
    }
}

#endif
