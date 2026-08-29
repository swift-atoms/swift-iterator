import Iterator_Once
import Iterator_Test_Support

private struct Token: ~Copyable {
    let id: Int
    init(_ id: Int) { self.id = id }
}

@Suite struct `Iterator.Once Tests` {
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
    @Suite struct Unit {}
}

extension `Iterator.Once Tests`.Unit {
    @Test
    func `once iterator yields one element then nil`() {
        var iter = Iterator.Once(42)
        #expect(iter.next() == 42)
        #expect(iter.next() == nil)
    }

    @Test
    func `once iterator stays exhausted across repeated calls`() {
        var iter = Iterator.Once("hello")
        #expect(iter.next() == "hello")
        #expect(iter.next() == nil)
        #expect(iter.next() == nil)
        #expect(iter.next() == nil)
    }

    @Test
    func `once iterator supports a move-only element`() {
        var iter = Iterator.Once(Token(7))

        var firstID: Int? = nil
        switch iter.next() {
        case .some(let token): firstID = token.id
        case .none: break
        }
        #expect(firstID == 7)

        var exhausted = false
        switch iter.next() {
        case .some: break
        case .none: exhausted = true
        }
        #expect(exhausted)
    }
}
