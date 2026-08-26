extension Iterator {

    @inlinable
    public static func repeating<Element>(_ element: Element) -> Iterator.Witness<Element, Never> {
        Self.Witness<Element, Never> { element }
    }
}
