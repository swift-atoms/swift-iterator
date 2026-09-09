# swift-iterator

## Prefix integration

The default-enabled `Prefix` trait supplies this package's interpretation of the
independent prefix selectors from swift-prefix. Use this package's library product;
no separate integration product is required.

`Prefix.Iterator` owns forward input and unread lookahead. Continue through the
same wrapper after selection. `forEach(in:_:)`, `forEach(from:_:)`, and
`prefixIterator()` preserve their existing consumption and ownership contracts.
These APIs moved from the Prefix module into Iterator; import Iterator to use them.
