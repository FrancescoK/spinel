# RBS extractor golden tests

Golden tests for `spinel_rbs_extract` — the tool that reads `*.rbs`
files and emits the line-oriented seed format the analyzer consumes
under `spinel --rbs DIR`. See `docs/rbs-extract.md` for the supported
subset.

The extractor is a pure, deterministic text transform (`*.rbs` in →
seed lines on stdout) and a compiled C binary, so it golden-tests
cleanly with **no Ruby at test time** — unlike the compile-and-run
fixtures under `test/`. This layer is also where RBS regressions are
actually visible: seeds are advisory, so most extractor bugs produce
identical *program* output and slip past the `test/*.rb` suite.

## Layout

Each case is one input/golden pair:

- `<name>.rbs` — input RBS source
- `<name>.seed.expected` — committed expected seed output

`make rbs-test` runs `spinel_rbs_extract <name>.rbs` for every case and
diffs stdout against the golden. It is a prerequisite of `make test`,
and skips gracefully when `vendor/rbs` has not been fetched.

`positions.rbs` also has a `.positions.expected` golden for `--positions`.
The harness runs that fixture with LF and CRLF line endings, normalizes only
the input path, and compares all seed records in order. Its UTF-8 comment,
repeated declaration line, and nested class protect source-line mapping.

## Adding or updating a case

1. Add (or edit) `<name>.rbs`.
2. `make regen-rbs-expected` to (re)generate every `.seed.expected`.
3. **Read the diff** — the goldens encode intended behavior, so confirm
   the change is what you meant before committing both files.

## Coverage

Single-file fixtures cover the documented subset: the scalar type
vocabulary, nominal types, `Array[T]` / `Hash[K,V]` tag selection,
nullable (`T?` / `T | nil`), heterogeneous-union → `poly`, member kinds
(`meth` / `cmeth` / `self?.` / `attr_*` / `@ivar`), unqualified
parent-scope resolution, first-overload-wins, and the signature- and
type-level shapes that drop a method wholesale.

Multi-file cross-file resolution (issue #658) is not covered here:
output ordering across files depends on `readdir`, which isn't portable
enough for a stable golden. The single-file `unqualified.rbs` exercises
the parent-scope fallback deterministically.
