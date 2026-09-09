#if Prefix
public import Prefix

extension Prefix.Through {
    public init<S: Swift.Sequence>(sequence: S) where Delimiter == [S.Element] {
        self.init(Array(sequence))
    }
}

#endif
