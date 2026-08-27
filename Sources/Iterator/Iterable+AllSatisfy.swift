extension Iterable where Self: ~Copyable & ~Escapable, Iterator.Failure == Never {

    @inlinable
    public borrowing func allSatisfy<E: Swift.Error>(
        _ predicate: (borrowing Iterator.Element) throws(E) -> Bool
    ) throws(E) -> Bool {
        try !contains(where: { (element: borrowing Iterator.Element) throws(E) -> Bool in
            try !predicate(element)
        })
    }
}
