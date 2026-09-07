import Iterator
import Iterator_Test_Support

private struct CountingIterator: Iterator::Iterator.`Protocol` {
    var n: Int
    init(upTo n: Int) { self.n = n }
}

extension CountingIterator {
    mutating func next() -> Int? {
        guard n > 0 else { return nil }
        defer { n -= 1 }
        return n
    }
}

@Suite struct `Iteration supports closure sources type erasure and repetition` {
    @Suite struct `Closure backed iterators yield values and remain exhausted` {}
    @Suite struct `Type erased iteration wraps a copyable source` {}
    @Suite struct `Repeating iteration continues yielding the same element` {}
    @Suite struct `No iteration boundary cases are defined` {}
    @Suite struct `No iteration integration cases are defined` {}
}

extension `Iteration supports closure sources type erasure and repetition`.`Closure backed iterators yield values and remain exhausted` {
    @Test
    func `closure-backed iterator yields then exhausts`() {
        var values = [1, 2, 3]
        var iter = Iteration<Int, Never> {
            guard !values.isEmpty else { return nil }
            return values.removeFirst()
        }

        #expect(iter.next() == 1)
        #expect(iter.next() == 2)
        #expect(iter.next() == 3)
        #expect(iter.next() == nil)
    }

    @Test
    func `empty closure-backed iterator yields nothing`() {
        var iter = Iteration<Int, Never> { nil }
        #expect(iter.next() == nil)
        #expect(iter.next() == nil)
    }
}

extension `Iteration supports closure sources type erasure and repetition`.`Type erased iteration wraps a copyable source` {
    @Test
    func `Type erased iteration wraps a copyable source iterator`() {
        let source = CountingIterator(upTo: 2)
        var iter = Iteration(source)

        #expect(iter.next() == 2)
        #expect(iter.next() == 1)
        #expect(iter.next() == nil)
    }
}

extension `Iteration supports closure sources type erasure and repetition`.`Repeating iteration continues yielding the same element` {
    @Test
    func `repeating factory yields the element forever`() {

        var iter = Iterator.repeating(7)
        #expect(iter.next() == 7)
        #expect(iter.next() == 7)
        #expect(iter.next() == 7)
    }
}
