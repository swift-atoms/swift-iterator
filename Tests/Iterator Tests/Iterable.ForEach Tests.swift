import Iterator
import Iterator_Test_Support

private struct IntSource: Iterator::Iterable {
    let values: [Int]
}

extension IntSource {
    @_lifetime(borrow self)
    borrowing func makeIterator() -> Iterator::Iterator.Chunk<Int> {
        Iterator::Iterator.Chunk(values.span)
    }
}

private struct IntCursor: Iterator::Iterable, ~Escapable {
    let values: Swift.Span<Int>

    @_lifetime(copy values)
    init(_ values: Swift.Span<Int>) {
        self.values = values
    }
}

extension IntCursor {
    @_lifetime(borrow self)
    borrowing func makeIterator() -> Iterator::Iterator.Chunk<Int> {
        Iterator::Iterator.Chunk(values)
    }
}

@Suite struct `Iterable traversal preserves order capabilities and typed failures` {
    @Suite struct `No iterable traversal boundary cases are defined` {}
    @Suite struct `No iterable traversal integration cases are defined` {}
    @Suite struct `Element traversal preserves repeatability and propagates body failures` {}
    @Suite struct `Element traversal accepts nonescapable iterables` {}
}

extension `Iterable traversal preserves order capabilities and typed failures`.`Element traversal preserves repeatability and propagates body failures` {
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

extension `Iterable traversal preserves order capabilities and typed failures`.`Element traversal accepts nonescapable iterables` {

    @Test
    func `forEach reaches a ~Escapable iterable`() {
        let values = [1, 2, 3, 4]
        var collected: [Int] = []
        let cursor = IntCursor(values.span)
        cursor.forEach { collected.append($0) }
        #expect(collected == [1, 2, 3, 4])
    }
}
