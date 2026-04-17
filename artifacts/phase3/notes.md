# Phase 3 Notes

- `index_load()` treats a missing `.pes/index` as an empty staging area, which matches the expected first-run behavior after `pes init`.
- `index_save()` sorts by path and writes through a temporary file plus `fsync()` before rename, so the on-disk index stays deterministic and crash-resistant.
- `index_add()` stores the blob first, then records the blob hash, mode, `mtime`, size, and relative path in the text index.
