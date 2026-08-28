public import Cardinal
public import Cardinal_Carrier
public import Carrier_Protocol

public protocol __IteratorChunkProtocol<Element, Failure>: ~Copyable, ~Escapable {

    associatedtype Element: ~Copyable

    associatedtype Failure: Swift.Error = Never

    @_lifetime(&self)
    mutating func next(
        maximumCount: some Carrier.`Protocol`<Cardinal>
    ) throws(Failure) -> Swift.Span<Element>

    mutating func skip(by maximumOffset: Int) throws(Failure) -> Int
}

extension __IteratorChunkProtocol
where
    Self: ~Copyable & ~Escapable,
    Element: ~Copyable
{

    @inlinable
    public mutating func skip(by maximumOffset: Int) throws(Failure) -> Int {
        var remainder = maximumOffset
        while remainder > 0 {
            let span = try next(maximumCount: Cardinal(UInt(remainder)))
            if span.isEmpty { break }
            remainder &-= span.count
        }
        return maximumOffset &- remainder
    }
}
