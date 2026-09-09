# swift-iterator

Iterator.Buffered owns a forward source and unread elements. `unread` replays
owned elements before advancing the base. Continue through the wrapper rather
than bypassing it. This capability is independent of search and is not arbitrary
checkpoint restoration. Buffered elements may be noncopyable but must be escapable.
Iterator.Standard adapts a Swift iterator; Iterator.Flattened materializes elements
from chunks. `bufferedIterator()` constructs these adapters for sequences/iterables.

Default-enabled Search and Repetition traits provide execution integrations:

- Cardinal ranges bound element delivery. Direct delivery supports scoped and
  noncopyable elements; chunk delivery borrows elements without copying.
- Repetition of a Predicate stops before a rejected element, retaining it unread.
- Search selection retains an excluded delimiter or includes it when selecting end.

Source failures remain distinct from selection/count failures through Either.
Already delivered outputs remain consumed on failure; pending candidate elements
are retained. No consumer callbacks are rolled back. Legacy Cursor operations are
outside this migration.
