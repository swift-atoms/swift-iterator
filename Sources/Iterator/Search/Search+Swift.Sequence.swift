#if Search
public import Search

extension Search {
    /// Accepts a single-pass delimiter by materializing it exactly once.
    public init<S: Swift.Sequence>(sequence: S) where Pattern == [S.Element] {
        self.init(Array(sequence))
    }
}

#endif
