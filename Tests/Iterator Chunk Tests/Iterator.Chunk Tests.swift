import Cardinal
import Cardinal_Carrier
import Carrier_Protocol
import Iterator_Chunk
import Iterator_Test_Support
import Testing

private struct DripBulk: Iterator.Chunk.`Protocol` {
    var storage: [Int]
    var pos: Int = 0
    init(_ storage: [Int]) { self.storage = storage }
}

extension DripBulk {
    typealias Element = Int
    typealias Failure = Never

    @_lifetime(&self)
    mutating func next(maximumCount: some Carrier.`Protocol`<Cardinal>) -> Span<Int> {
        guard pos < storage.count else { return storage.span.extracting(pos..<pos) }
        let start = pos
        pos += 1
        return storage.span.extracting(start..<(start + 1))
    }
}

@Suite struct `Iterator.Chunk Tests` {
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite struct Unit {}
}

extension `Iterator.Chunk Tests`.Unit {
    @Test
    func `next yields a borrowed span of the next element`() {
        var iter = DripBulk([10, 20, 30])
        let span = iter.next(maximumCount: Cardinal(4))

        let count = span.count
        let first = span[0]
        #expect(count == 1)
        #expect(first == 10)
    }

    @Test
    func `next returns an empty span at exhaustion`() {
        var iter = DripBulk([Int]())
        let span = iter.next(maximumCount: Cardinal(1))
        let isEmpty = span.isEmpty
        #expect(isEmpty)
    }

    @Test
    func `derived next drains the bulk iterator one element at a time`() {
        var iter = DripBulk([1, 2, 3])
        #expect(iter.next() == 1)
        #expect(iter.next() == 2)
        #expect(iter.next() == 3)
        #expect(iter.next() == nil)
    }

    @Test
    func `Iterator.Chunk lends chunked sub-spans up to maximumCount, then exhausts`() {
        let array = [10, 20, 30, 40, 50]
        var iter = Iterator.Chunk(array.span)

        do {
            let chunk = iter.next(maximumCount: Cardinal(2))
            let count = chunk.count
            let a = chunk[0]
            let b = chunk[1]
            #expect(count == 2)
            #expect(a == 10)
            #expect(b == 20)
        }
        do {
            let chunk = iter.next(maximumCount: Cardinal(2))
            let count = chunk.count
            let a = chunk[0]
            let b = chunk[1]
            #expect(count == 2)
            #expect(a == 30)
            #expect(b == 40)
        }

        #expect(iter.next() == 50)
        #expect(iter.next() == nil)
    }

    @Test
    func `skip preserves typed cardinal boundaries and reports the actual count`() {
        var iter = DripBulk([10, 20, 30])

        let first: Cardinal = iter.skip(by: Cardinal(2))
        #expect(first == Cardinal(2))

        let exhausted: Cardinal = iter.skip(by: Cardinal(4))
        #expect(exhausted == Cardinal(1))
        #expect(iter.next() == nil)
    }
}
