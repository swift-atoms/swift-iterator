extension Iterator {

    public struct Buffered<Base: Iterating & ~Copyable & ~Escapable, Element: ~Copyable, Failure: Swift::Error>: Iterating, ~Copyable, ~Escapable
    where Base.Element == Element, Base.Failure == Failure {
        private var base: Base
        private var pending: Node?

        private final class Node {
            var element: Element?
            let next: Node?
            init(_ element: consuming Element, next: Node?) {
                self.element = .some(consume element)
                self.next = next
            }
        }

        @_lifetime(copy base)
        public init(_ base: consuming Base) {
            self.base = base
            self.pending = nil
        }

        public mutating func next() throws(Failure) -> Element? {
            if let node = pending {
                pending = node.next
                var result: Element? = nil
                swap(&result, &node.element)
                return result
            }
            return try base.next()
        }

        public mutating func unread(_ element: consuming Element) {
            pending = Node(element, next: pending)
        }
    }
}

extension Iterator::Iterator.Buffered: Escapable
where Base: ~Copyable & Escapable, Element: ~Copyable {}
