# Phase 2 Notes

- `tree_from_index()` builds nested tree objects by grouping staged paths on directory prefixes and recursively emitting subtree objects before the root tree.
- Empty trees are serialized safely by allocating at least one byte, which avoids allocator edge cases when a tree has zero entries.
- The raw capture in `2B_tree_xxd.txt` shows the expected binary layout: ASCII octal mode, a space, the entry name, a null byte, and then the 32-byte object hash.
