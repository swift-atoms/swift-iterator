#if Empty
public import Empty

extension Empty: Iterator.`Protocol` where Element: ~Copyable & ~Escapable {

    public typealias Failure = Never

    @inlinable
    @_lifetime(&self)
    public mutating func next() -> Element? {
        nil
    }
}
#endif
