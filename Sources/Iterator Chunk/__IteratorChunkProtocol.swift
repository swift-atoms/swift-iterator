public import Cardinal
public import Cardinal_Carrier
public import Cardinal_Subtract
public import Carrier_Protocol

public protocol __IteratorChunkProtocol<Element, Failure>: ~Copyable, ~Escapable {

    associatedtype Element: ~Copyable

    associatedtype Failure: Swift.Error = Never

    @_lifetime(&self)
    mutating func next(
        maximumCount: some Carrier.`Protocol`<Cardinal>
    ) throws(Failure) -> Swift.Span<Element>

    mutating func skip(
        by maximumOffset: some Carrier.`Protocol`<Cardinal>
    ) throws(Failure) -> Cardinal
}

extension __IteratorChunkProtocol
where
    Self: ~Copyable & ~Escapable,
    Element: ~Copyable
{

    @inlinable
    public mutating func skip(
        by maximumOffset: some Carrier.`Protocol`<Cardinal>
    ) throws(Failure) -> Cardinal {
        let requested = maximumOffset.underlying
        var remainder = requested
        while remainder > .zero {
            let span = try next(maximumCount: remainder)
            if span.isEmpty { break }
            remainder = remainder.subtract.saturating(
                Cardinal(UInt(bitPattern: span.count))
            )
        }
        return requested.subtract.saturating(remainder)
    }
}
