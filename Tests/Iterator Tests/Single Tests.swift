#if Single
import Iterator
import Testing

@Suite
struct `Single Tests` {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension `Single Tests`.Unit {
    @Test
    func `single vends a span iterator yielding its element once`() {
        let single = Single(42)
        var collected: [Int] = []
        single.forEach { collected.append($0) }
        #expect(collected == [42])
    }

    @Test
    func `makeIterator borrows, so the container stays multipass`() {
        let single = Single("x")

        var first: [String] = []
        single.forEach { first.append($0) }
        var second: [String] = []
        single.forEach { second.append($0) }
        #expect(first == ["x"])
        #expect(second == ["x"])
    }
}
#endif
