#if Empty
import Iterator
import Testing

@Suite struct `Empty Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `Empty Tests`.Unit {
    @Test
    func `empty iterator yields nothing`() {
        var iter = Empty<Int>()
        #expect(iter.next() == nil)
    }
}

extension `Empty Tests`.`Edge Case` {
    @Test
    func `empty iterator stays exhausted across repeated calls`() {
        var iter = Empty<String>()
        #expect(iter.next() == nil)
        #expect(iter.next() == nil)
        #expect(iter.next() == nil)
    }
}
#endif
