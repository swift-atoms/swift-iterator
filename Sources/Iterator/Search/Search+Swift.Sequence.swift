#if Search
public import Search

extension Search {

    public init<S: Swift.Sequence>(sequence: S) where Pattern == [S.Element] {
        self.init(Array(sequence))
    }
}

#endif
