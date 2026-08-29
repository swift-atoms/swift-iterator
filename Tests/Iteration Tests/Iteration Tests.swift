import Iterator_Protocol
import Iterator_Test_Support
import Iterator_Witness

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

@Suite struct `Iteration Tests` {
    @Suite struct Unit {}
    @Suite struct `Type Erasure` {}
    @Suite struct Repeating {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `Iteration Tests`.Unit {
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

extension `Iteration Tests`.`Type Erasure` {
    @Test
    func `wraps a Copyable source iterator`() {
        let source = CountingIterator(upTo: 2)
        var iter = Iteration(source)

        #expect(iter.next() == 2)
        #expect(iter.next() == 1)
        #expect(iter.next() == nil)
    }
}

extension `Iteration Tests`.Repeating {
    @Test
    func `repeating factory yields the element forever`() {

        var iter = Iterator.repeating(7)
        #expect(iter.next() == 7)
        #expect(iter.next() == 7)
        #expect(iter.next() == 7)
    }
}
