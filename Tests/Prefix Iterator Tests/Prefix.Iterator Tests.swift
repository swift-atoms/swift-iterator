#if Prefix
import Prefix
import Predicate
import Iterator
import Either
import Testing

@Suite
struct `Prefix.Iterator Tests` {
    @Test
    func `a predicate retains the first rejected element`() throws {
        var input = "123x".prefixIterator()
        var selected = ""
        try Prefix.While<Character>({ $0.isNumber }).forEach(in: &input) {
            selected.append($0)
        }
        #expect(selected == "123")
        #expect(input.next() == "x")
        #expect(input.next() == nil)
    }

    @Test
    func `up to retains the complete delimiter and through consumes it`() throws {
        var input = "aaab!".prefixIterator()
        var selected = ""
        try Prefix.UpTo("aab").forEach(in: &input) { selected.append($0) }
        #expect(selected == "a")
        selected = ""
        try Prefix.Through("aab").forEach(in: &input) { selected.append($0) }
        #expect(selected == "aab")
        #expect(input.next() == "!")
    }

    @Test
    func `a missing delimiter preserves pending candidates`() {
        var input = "abc-".prefixIterator()
        var selected = ""
        #expect(throws: Either<Prefix.UpTo<String>.Error, Never>.left(.delimiterNotFound)) {
            try Prefix.UpTo("--").forEach(in: &input) { selected.append($0) }
        }
        #expect(selected == "abc")
        #expect(input.next() == "-")
    }

    @Test
    func `maximum count performs no extra read`() throws {
        let reads = Counts()
        var input = Prefix.Iterator(Numbers(counts: reads))
        try Prefix(maximum: 2).forEach(in: &input) { _ in }
        #expect(reads.read == 2)
        #expect(input.next() == 2)
    }

    @Test
    func `minimum failure keeps partial delivery explicit`() {
        var input = [1].prefixIterator()
        var selected: [Int] = []
        #expect(throws: Either<Prefix.Error, Never>.left(.insufficientElements(minimum: 2, actual: 1))) {
            try Prefix(minimum: 2).forEach(in: &input) { selected.append($0) }
        }
        #expect(selected == [1])
        #expect(input.next() == nil)
    }

    @Test
    func `noncopyable elements are borrowed for predicates and moved exactly once`() throws {
        let counts = Counts()
        do {
            var input = Prefix.Iterator(Tokens(counts: counts))
            var values: [Int] = []
            try Prefix.While<Token> { $0.value < 2 }.forEach(in: &input) {
                values.append($0.value)
            }
            #expect(values == [0, 1])
            #expect(counts.destroyed == 2)
            if let rejected = input.next() {
                let value = rejected.value
                #expect(value == 2)
            } else {
                Issue.record("Expected the rejected element to remain available")
            }
        }
        #expect(counts.destroyed == 3)
    }

    @Test
    func `a scoped source can retain owned lookahead`() throws {
        let values = [1, 2, 3]
        var input = Prefix.Iterator(Borrowed(values.span))
        var selected: [Int] = []
        try Prefix.While<Int> { $0 < 3 }.forEach(in: &input) { selected.append($0) }
        #expect(selected == [1, 2])
        #expect(input.next() == 3)
    }

    @Test
    func `count execution delivers scoped elements inside their borrow`() throws {
        let values = [1, 2, 3]
        var input = Loans(values.span)
        var selected: [Int] = []
        let positive = Predicate<Loan> { $0.values[0] > 0 }
        let selectedPredicate = positive.and(.always)
        try Prefix(maximum: 2).forEach(in: &input) {
            if selectedPredicate($0) { selected.append($0.values[0]) }
        }
        #expect(selected == [1, 2])
    }

    @Test
    func `upstream failures remain distinct and replay pending candidates`() throws {
        var input = Prefix.Iterator(Failing())
        #expect(throws: Either<Prefix.UpTo<[Int]>.Error, Fault>.right(.unavailable)) {
            try Prefix.UpTo([1, 2]).forEach(in: &input) { _ in }
        }
        #expect(try input.next() == 1)
    }
}

private final class Counts { var read = 0; var destroyed = 0 }
private struct Numbers: Iterating, ~Copyable {
    let counts: Counts
    mutating func next() -> Int? {
        defer { counts.read += 1 }
        return counts.read
    }
}
private struct Token: ~Copyable {
    let value: Int
    let counts: Counts
    deinit { counts.destroyed += 1 }
}
private struct Tokens: Iterating, ~Copyable {
    let counts: Counts
    mutating func next() -> Token? {
        defer { counts.read += 1 }
        return Token(value: counts.read, counts: counts)
    }
}
private struct Borrowed: Iterating, ~Copyable, ~Escapable {
    let values: Span<Int>
    var offset = 0
    @_lifetime(copy values)
    init(_ values: Span<Int>) { self.values = values }
    mutating func next() -> Int? {
        guard offset < values.count else { return nil }
        defer { offset += 1 }
        return values[offset]
    }
}
private struct Loan: ~Copyable, ~Escapable {
    let values: Span<Int>
    @_lifetime(copy values)
    init(_ values: Span<Int>) { self.values = values }
}
private struct Loans: Iterating, ~Copyable, ~Escapable {
    let values: Span<Int>
    var offset = 0
    @_lifetime(copy values)
    init(_ values: Span<Int>) { self.values = values }
    @_lifetime(&self)
    mutating func next() -> Loan? {
        guard offset < values.count else { return nil }
        defer { offset += 1 }
        return Loan(values.extracting(offset..<(offset + 1)))
    }
}
private enum Fault: Error, Equatable { case unavailable }
private struct Failing: Iterating {
    var count = 0
    mutating func next() throws(Fault) -> Int? {
        guard count == 0 else { throw .unavailable }
        count += 1
        return 1
    }
}

extension `Prefix.Iterator Tests` {
    @Test
    func `a Swift Sequence is traversed only once`() throws {
        let source = SinglePass()
        var input = source.prefixIterator()
        var values: [Int] = []
        try Prefix(maximum: 2).forEach(in: &input) { values.append($0) }
        #expect(values == [0, 1])
        #expect(source.iterations == 1)
        #expect(input.next() == 2)
    }

    @Test
    func `Iterable supports both borrowed delivery and owned lookahead`() throws {
        let counts = Counts()
        let source = Chunks(counts: counts)
        var values: [Int] = []
        try Prefix(maximum: 2).forEach(from: source) { values.append($0) }
        #expect(values == [0, 1])
        var input = source.prefixIterator()
        try Prefix.While<Int> { $0 < 3 }.forEach(in: &input) { values.append($0) }
        #expect(values == [0, 1, 2])
        #expect(input.next() == 3)
    }
}

private final class SinglePass: Swift.Sequence, Swift.IteratorProtocol {
    var iterations = 0
    var count = 0
    func makeIterator() -> SinglePass { iterations += 1; return self }
    func next() -> Int? { defer { count += 1 }; return count }
}

private struct Chunks: Iterable, ~Copyable {
    let counts: Counts
    @_lifetime(borrow self)
    borrowing func makeIterator() -> Iterator::Iterator.Materializing<Numbers> {
        Iterator::Iterator.Materializing(Numbers(counts: counts))
    }
}

extension `Prefix.Iterator Tests` {
    @Test
    func `an owned Swift iterator can escape its construction scope`() {
        var input = ownedIterator()
        #expect(input.next() == 1)
    }

    @Test
    func `single pass delimiter construction materializes once`() throws {
        var values = [1, 2].makeIterator()
        let delimiter = AnyIterator { values.next() }
        let selection = Prefix.UpTo(sequence: delimiter)
        var first = [0, 1, 2, 3].prefixIterator()
        var firstOutput: [Int] = []
        try selection.forEach(in: &first) { firstOutput.append($0) }
        #expect(firstOutput == [0])
        var second = [9, 1, 2, 4].prefixIterator()
        var secondOutput: [Int] = []
        try selection.forEach(in: &second) { secondOutput.append($0) }
        #expect(secondOutput == [9])
    }
}

private func ownedIterator() -> Prefix.Iterator<Prefix.Iteration<IndexingIterator<[Int]>>, Never> {
    [1, 2].prefixIterator()
}

#endif
