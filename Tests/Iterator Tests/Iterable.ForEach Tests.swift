import Iterator
import Testing

private struct IntSource: Iterable {
    let values: [Int]
}

extension IntSource {
    @_lifetime(borrow self)
    borrowing func makeIterator() -> Iterator.Iterator.Chunk<Int> {
        Iterator.Iterator.Chunk(values.span)
    }
}

private struct IntCursor: Iterable, ~Escapable {
    let values: Swift.Span<Int>

    @_lifetime(copy values)
    init(_ values: Swift.Span<Int>) {
        self.values = values
    }
}

extension IntCursor {
    @_lifetime(borrow self)
    borrowing func makeIterator() -> Iterator.Iterator.Chunk<Int> {
        Iterator.Iterator.Chunk(values)
    }
}

@Suite struct `Iterable ForEach Tests` {
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite struct Unit {}
    @Suite struct `Escapability` {}
}

extension `Iterable ForEach Tests`.Unit {
    @Test
    func `forEach visits every element in order`() {
        let source = IntSource(values: [1, 2, 3])
        var collected: [Int] = []
        source.forEach { collected.append($0) }
        #expect(collected == [1, 2, 3])
    }

    @Test
    func `forEach is non-destructive — the container iterates again`() {
        let source = IntSource(values: [10, 20])
        var first: [Int] = []
        source.forEach { first.append($0) }
        var second: [Int] = []
        source.forEach { second.append($0) }
        #expect(first == [10, 20])
        #expect(second == [10, 20])
    }

    @Test
    func `forEach propagates the body's typed error, stopping iteration`() {
        enum Stop: Swift.Error { case now }
        let source = IntSource(values: [1, 2, 3, 4])
        var seen: [Int] = []
        var threw = false
        do throws(Stop) {
            try source.forEach { element throws(Stop) in
                seen.append(element)
                if element == 2 { throw Stop.now }
            }
        } catch {
            threw = true
        }
        #expect(threw)
        #expect(seen == [1, 2])
    }
}

extension `Iterable ForEach Tests`.`Escapability` {

    @Test
    func `forEach reaches a ~Escapable iterable`() {
        let values = [1, 2, 3, 4]
        var collected: [Int] = []
        let cursor = IntCursor(values.span)
        cursor.forEach { collected.append($0) }
        #expect(collected == [1, 2, 3, 4])
    }
}
