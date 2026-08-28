# Iterator Primitives

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)
[![CI](https://github.com/swift-atoms/swift-iterator/actions/workflows/ci.yml/badge.svg)](https://github.com/swift-atoms/swift-iterator/actions/workflows/ci.yml)

Single-pass iteration in three composable pieces: a protocol you conform to (`Iterator.Protocol`), a closure-backed type-erased witness (`Iteration`), and an attachable capability (`Iterable`) that gives any container `forEach` / `reduce` / `first` / `contains` / `allSatisfy`.

Unlike the standard library's `IteratorProtocol`, the element and the iterator itself may be `~Copyable` and `~Escapable`, and failure is a typed-throws `Failure` rather than `any Error` — this is the move-only, typed iterator the stdlib can't express.

---

## Key Features

- **Move-only iteration** — `Iterator.Protocol` admits `~Copyable & ~Escapable` conformers *and* `~Copyable & ~Escapable` elements; `next()` returns `Element?` under `@_lifetime(&self)`. The stdlib `IteratorProtocol` requires `Copyable` throughout.
- **Typed-throws failure** — the protocol carries a `Failure` type, so a failable iterator surfaces its precise error type at compile time instead of erasing to `any Error`.
- **Type-erased witness** — `Iteration<Element, Failure>` (canonically `Iterator.Witness`) wraps any closure, or any `Copyable` source iterator, into a single value.
- **Attachable terminals** — conform a container to `Iterable` with one `makeIterator()` and get `forEach`, `reduce(into:)`, `first(where:)`, `contains(where:)`, and `allSatisfy(_:)` for free; a multipass container can serve several terminals non-destructively.
- **Trivial iterators** — `Once<Element>` (one owned element, move-only) and `Empty<Element>` (zero elements), plus `Iterator.repeating(_:)` for an endlessly-repeated `Copyable` value.

---

## Quick Start

Conform a type to the iterator protocol — it works for move-only `Self` and elements:

```swift
import Iterator

struct Countdown: Iterator.`Protocol` {
    var n: Int
    mutating func next() -> Int? {
        guard n > 0 else { return nil }
        defer { n -= 1 }
        return n
    }
}

var c = Countdown(n: 3)
c.next()   // 3
c.next()   // 2
```

Erase any closure — or any `Copyable` iterator — into one witness value, and repeat a value forever:

```swift
var values = [1, 2, 3]
var iter = Iteration<Int, Never> {
    values.isEmpty ? nil : values.removeFirst()
}
iter.next()   // 1
iter.next()   // 2

var sevens = Iterator.repeating(7)
sevens.next() // 7  (forever)
```

Make a container `Iterable` with one method and get terminals for free:

```swift
import Iterator_Chunk

struct IntSource: Iterable {
    let values: [Int]
    // Inside an `Iterable`, `Iterator` is the protocol's associated type,
    // so the span-backed chunk iterator is module-qualified:
    @_lifetime(borrow self)
    borrowing func makeIterator() -> Iterator_Chunk.Iterator.Chunk<Int> {
        Iterator_Chunk.Iterator.Chunk(values.span)
    }
}

let source = IntSource(values: [1, 2, 3, 4])
source.contains { $0 > 3 }            // true
source.first { $0 > 2 }               // 3
source.reduce(into: 0) { $0 += $1 }   // 10
```

---

## Installation

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-atoms/swift-iterator.git", branch: "main")
]
```

Add the umbrella product to your target:

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Iterator", package: "swift-iterator")
    ]
)
```

Or depend on a narrower product (e.g. `Iterator Protocol` for just the protocol, `Iterator Witness Primitives` for the witness) — see Architecture.

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26 (or the corresponding Linux / Windows toolchain).

---

## Architecture

| Product | Contents | When to import |
|---------|----------|----------------|
| `Iterator Primitives` | Umbrella — protocol, witness, `Iterable` + terminals, `Once`, repetition | Most consumers |
| `Iterator Protocol` | `Iterator.Protocol` (alias `Iterating`) — the agent protocol only | Conforming a custom iterator with no other surface |
| `Iterator Witness Primitives` | `Iteration` / `Iterator.Witness` type-erased witness + `Iterator.repeating(_:)` | Type-erasing closures or `Copyable` iterators |
| `Iterable` | The `Iterable` attachable + terminals (`forEach` / `reduce` / `first` / `contains` / `allSatisfy`) | Adding terminals to a container |
| `Iterator Once Primitives` | `Once<Element>` — the one-element owned iterator | The single-element case |
| `Iterator Chunk Primitives` | `Iterator.Chunk` — a `Span`-backed bulk iterator | Iterating over a `Span` |
| `Iterator Primitive` | The bare `Iterator` namespace enum | Namespace only (rare) |
| `Iterator Test Support` | Re-exports for downstream test targets | Test target only |

`Iterable` defines a container in terms of `Iterator.Protocol` (`makeIterator()`); the dependency is strictly one-way, so iteration carries no knowledge of any sequence or collection layer above it.

---

## Platform Support

| Platform         | CI  | Status       |
|------------------|-----|--------------|
| macOS 26         | Yes | Full support |
| Linux            | Yes | Full support |
| Windows          | Yes | Full support |
| iOS/tvOS/watchOS | —   | Supported    |
| Swift Embedded   | —   | Supported    |

---

## Related Packages

- [`swift-either`](https://github.com/swift-atoms/swift-either) — `Either`, used by the `Iterable` terminals.
- [`swift-cardinal`](https://github.com/swift-atoms/swift-cardinal) — `Cardinal`, the counting type used in the bulk-iteration tier.
- [`swift-carrier`](https://github.com/swift-atoms/swift-carrier) — `Carrier`, backing the span-based `Iterator.Chunk`.

---

## Community

<!-- BEGIN: discussion -->
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
