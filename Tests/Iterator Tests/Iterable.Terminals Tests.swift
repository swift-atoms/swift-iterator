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

@Suite struct `Iterable terminal operations inspect and reduce elements without consumption` {
    @Suite struct `No iterable terminal boundary cases are defined` {}
    @Suite struct `No iterable terminal integration cases are defined` {}
    @Suite struct `Iterable terminal operations preserve matches reductions and repeatability` {}
}

extension `Iterable terminal operations inspect and reduce elements without consumption`.`Iterable terminal operations preserve matches reductions and repeatability` {
    @Test
    func `contains(where:) is true at the first match, false when none matches`() {
        let source = IntSource(values: [1, 2, 3])
        #expect(source.contains { $0 == 2 })
        #expect(!source.contains { $0 == 9 })
    }

    @Test
    func `first(where:) returns the first match or nil`() {
        let source = IntSource(values: [1, 2, 3, 4])
        #expect(source.first { $0 > 2 } == 3)
        #expect(source.first { $0 > 9 } == nil)
    }

    @Test
    func `reduce(into:) folds across every element`() {
        let source = IntSource(values: [1, 2, 3, 4])
        let sum = source.reduce(into: 0) { accumulator, element in
            accumulator += element
        }
        #expect(sum == 10)
    }

    @Test
    func `terminals are non-destructive — the same container serves several`() {
        let source = IntSource(values: [5, 6, 7])
        #expect(source.contains { $0 == 6 })
        #expect(source.first { $0 > 5 } == 6)
        let sum = source.reduce(into: 0) { $0 += $1 }
        #expect(sum == 18)
    }
}
