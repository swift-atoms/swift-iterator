#if Prefix
public import Prefix

extension Prefix.UpTo {
    /// Accepts a single-pass delimiter by materializing it exactly once.
    public init<S: Swift.Sequence>(sequence: S) where Delimiter == [S.Element] {
        self.init(Array(sequence))
    }
}

#endif
