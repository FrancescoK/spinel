# Spinel documentation

User documentation for Spinel, the whole-program ahead-of-time Ruby→C compiler.
Start here, then open the topic you need.

## For users

- **[spin.md](spin.md)** -- projects and packages with `spin`:
  scaffold, dependencies (path / git / index), lockfile, tests, vendoring,
  and native C in packages. Start here to build anything bigger than one file.
- **[limitations.md](limitations.md)** -- what an AOT compiler can and cannot do.
  The honest catalogue of where Spinel differs from CRuby, and why. Read this
  first if something behaves unexpectedly.
- **[require.md](require.md)** -- how `require` works: which stdlib needs which
  `require`, what an absent or unsatisfiable `require` does, and how to provide
  a feature of your own with `-I`.
- **[FFI.md](FFI.md)** -- call C functions directly from Spinel Ruby, with no
  extension build step: declarations in the source become direct C call sites.
- **[rbs-extract.md](rbs-extract.md)** -- seed the type inferencer with `.rbs`
  signatures via `spinel --rbs DIR`: the supported RBS subset, what a seed buys,
  and why a seed is an assertion you are trusted to get right rather than a hint.
- **[inline-rbs.md](inline-rbs.md)** -- the same signatures written as RBS
  comments in the Ruby source (`#: (Integer) -> String`, `# @rbs x: Integer`):
  the supported forms, where an annotation attaches, and what Spinel says about
  one it does not apply.
- **[float-rounding.md](float-rounding.md)** -- the return type of
  `Float#ceil`/`#floor`/`#round`/`#truncate`, where Spinel's static typing meets
  CRuby's value-dependent rule.
- **[int-overflow.md](int-overflow.md)** -- `--int-overflow=raise|wrap|promote`:
  what happens when an `Integer` crosses Spinel's machine-word boundary
  (64 bits on a 64-bit target, 32 on i386 and wasm32), and how the width
  follows the target.
- **[emit-types.md](emit-types.md)** -- `--emit-types`: every typed node's
  span, kind, name and RBS, and the diagnostics (the widened slot, the
  refusals) as JSON, for editor tools.
- **[wasm.md](wasm.md)** -- `--target=wasm32-wasi`: the program as a
  WebAssembly module for wasmtime, Node or a browser, what it needs (the
  wasi-sdk, `make wasm-rt`) and what the target does without.
- **[portability.md](portability.md)** -- the GNU C extensions behind
  `lib/sp_compat.h`, their standard C fallbacks, `make PORTABLE=1` to build
  with every fallback, and what still needs a GNU-compatible compiler.
- **[profiling.md](profiling.md)** -- where the time goes (`--profile` plus any
  frame-pointer sampler) and where the allocations come from
  (`SPINEL_ALLOC_REPORT`, with per-site attribution).
- **[../tools/README.md](../tools/README.md)** -- the in-tree companion tools:
  `spinel-doctor` (one health report per program: build, silent degradations,
  inference, and static performance advice), `spinel-reduce` (minimal-repro
  reducer), `spinel-flatten`.
- **[thread.md](thread.md)** -- `Thread` as true M:N parallelism with no GVL:
  the execution model, the supported API, and the data-race semantics that
  follow from having no global lock.

## Internals

How the compiler is built and where it is going. Not needed to *use* Spinel.

- **[internals/AST.md](internals/AST.md)** -- the text AST the parser emits and
  the rest of the compiler consumes.
- **[internals/analyze-ir.md](internals/analyze-ir.md)** -- the analyze ↔ codegen
  contract (the shared in-memory `Compiler` model).
- **[internals/gc.md](internals/gc.md)** -- the collector: two heaps, the marker
  byte that identifies a heap string, explicit roots, a full mark with a
  generational sweep, and the limits that follow from having no write barrier.
- **[internals/thread-mn-design.md](internals/thread-mn-design.md)** -- the M:N
  thread scheduler: green threads on the fiber substrate, per-worker run queues
  and work stealing, stop-the-world GC, the preemption monitor. A working
  document, not a user guarantee (the user contract is in [thread.md](thread.md)).
