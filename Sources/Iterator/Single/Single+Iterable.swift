#if Single
public import Single

public typealias SingleOnceIterator<Element: Copyable> = Iterator.Once<Element>

public typealias SingleMaterializingIterator<Element: Copyable> =
    Iterator.Materializing<SingleOnceIterator<Element>>

extension Single: Iterable where Element: Copyable {

    public typealias Iterator = SingleMaterializingIterator<Element>

    @inlinable
    @_lifetime(borrow self)
    public borrowing func makeIterator()
        -> SingleMaterializingIterator<Element>
    {
        SingleMaterializingIterator(SingleOnceIterator(element))
    }
}
#endif
