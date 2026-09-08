import Cardinal
import Carrier
import Iterator
import Testing

private final class DemandReadLog {
    var calls = 0
}

private struct ChunkDemand: Carrier.`Protocol` {
    let underlying: Cardinal

    init(_ underlying: Cardinal) {
        self.underlying = underlying
    }
}

private struct OwnedDemandSource: Iterator.`Protocol`, ~Copyable {
    let values: [Int]
    let log: DemandReadLog
    var position = 0

    mutating func next() -> Int? {
        log.calls += 1
        guard position < values.count else { return nil }
        defer { position += 1 }
        return values[position]
    }
}

private struct BorrowedDemandSource: Iterator.`Protocol`, ~Copyable, ~Escapable {
    let values: Swift.Span<Int>
    let log: DemandReadLog
    var position = 0

    @_lifetime(copy values)
    init(_ values: Swift.Span<Int>, log: DemandReadLog) {
        self.values = values
        self.log = log
    }

    mutating func next() -> Int? {
        log.calls += 1
        guard position < values.count else { return nil }
        defer { position += 1 }
        return values[position]
    }
}

private enum DemandReadFailure: Swift.Error, Equatable {
    case unavailable
}

private struct FailingDemandSource: Iterator.`Protocol`, ~Copyable {
    let log: DemandReadLog

    mutating func next() throws(DemandReadFailure) -> Int? {
        log.calls += 1
        throw .unavailable
    }
}

@Suite
struct `Zero chunk demand preserves iterator values and source effects` {
    @Test(arguments: [UInt(1), 4, UInt.max])
    func `Materializing preserves an owned source across zero requests`(maximumCount: UInt) {
        let log = DemandReadLog()
        var iterator = Iterator.Materializing(OwnedDemandSource(values: [10, 20], log: log))

        for (index, expected) in [10, 20].enumerated() {
            let zeroIsEmpty = iterator.next(maximumCount: ChunkDemand(.zero)).isEmpty
            #expect(zeroIsEmpty)
            #expect(log.calls == index)
            let skipped = iterator.skip(by: ChunkDemand(.zero))
            #expect(skipped == .zero)
            #expect(log.calls == index)

            let chunk = iterator.next(maximumCount: ChunkDemand(Cardinal(maximumCount)))
            let count = chunk.count
            let value = chunk.isEmpty ? nil : chunk[0]
            #expect(count == 1)
            #expect(value == expected)
        }

        let exhausted = iterator.next(maximumCount: Cardinal.one).isEmpty
        #expect(exhausted)
        #expect(log.calls == 3)
        let zeroIsEmpty = iterator.next(maximumCount: Cardinal.zero).isEmpty
        #expect(zeroIsEmpty)
        #expect(log.calls == 3)
    }

    @Test
    func `Materializing preserves a nonescapable source across zero requests`() {
        let values = [30, 40]
        let log = DemandReadLog()
        var iterator = Iterator.Materializing(BorrowedDemandSource(values.span, log: log))

        let zeroIsEmpty = iterator.next(maximumCount: Cardinal.zero).isEmpty
        #expect(zeroIsEmpty)
        #expect(log.calls == 0)
        #expect(iterator.next() == 30)
        let middleIsEmpty = iterator.next(maximumCount: Cardinal.zero).isEmpty
        #expect(middleIsEmpty)
        #expect(log.calls == 1)
        #expect(iterator.next() == 40)
        #expect(iterator.next() == nil)
        let exhaustedIsEmpty = iterator.next(maximumCount: Cardinal.zero).isEmpty
        #expect(exhaustedIsEmpty)
        #expect(log.calls == 3)
    }

    @Test
    func `Materializing attempts a fallible read only for positive demand`() throws {
        let log = DemandReadLog()
        var iterator = Iterator.Materializing(FailingDemandSource(log: log))

        let zeroIsEmpty = try iterator.next(maximumCount: Cardinal.zero).isEmpty
        #expect(zeroIsEmpty)
        #expect(log.calls == 0)

        do throws(DemandReadFailure) {
            _ = try iterator.next(maximumCount: Cardinal.one)
            Issue.record("A positive request must surface the source failure")
        } catch {
            #expect(error == .unavailable)
        }
        #expect(log.calls == 1)

        let zeroAfterFailureIsEmpty = try iterator.next(maximumCount: Cardinal.zero).isEmpty
        #expect(zeroAfterFailureIsEmpty)
        #expect(log.calls == 1)
    }

    @Test
    func `Borrowed chunks preserve their position across zero requests and skips`() {
        let values = [10, 20, 30]
        var iterator = Iterator.Chunk(values.span)

        let initialIsEmpty = iterator.next(maximumCount: Cardinal.zero).isEmpty
        #expect(initialIsEmpty)
        #expect(iterator.skip(by: Cardinal.zero) == .zero)
        #expect(iterator.next() == 10)
        let middleIsEmpty = iterator.next(maximumCount: Cardinal.zero).isEmpty
        #expect(middleIsEmpty)

        do {
            let tail = iterator.next(maximumCount: Cardinal.max)
            var actual: [Int] = []
            for index in tail.indices { actual.append(tail[index]) }
            #expect(actual == [20, 30])
        }

        let finalIsEmpty = iterator.next(maximumCount: Cardinal.zero).isEmpty
        #expect(finalIsEmpty)
        #expect(iterator.skip(by: Cardinal.zero) == .zero)
        #expect(iterator.next() == nil)
    }
}
