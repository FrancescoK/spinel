# Analyze ↔ Codegen contract

Spinel runs analysis and code generation as two phases of a **single
binary**, sharing one in-memory state object:

```
.rb  ──[sp_parse_file]──▶  NodeTable
        ──[analyze_program(c)]──▶  Compiler (filled)  ──[codegen emits]──▶  .c
```

`codegen_program(nt)` (`src/codegen.c`) builds a `Compiler`, calls
`analyze_program(c)` to populate it, then walks the AST emitting C. The
analyzer and code generator are the same process and share heap state;
nothing is serialized between them.

> **Historical note.** The retired Ruby self-host ran `spinel_analyze`
> and `spinel_codegen` as *separate* binaries that communicated through a
> text `.ir` file (`SPINEL-IR v1`, with `INT` / `STR` / `SA` / `IA` / `T`
> / `NM` / `SN` / `ST` records). That file no longer exists. The C
> rewrite folded both stages into one binary, so the `.ir` round-trip,
> its percent-encoding, and the four-way bootstrap fixpoint it backed are
> all gone. `src/compiler.h` keeps the lineage explicit: *"its field set
> corresponds to the legacy .ir dump."*

## The shared object: `Compiler`

`src/compiler.h` defines `Compiler` -- the modern equivalent of the old
`.ir`. Everything analysis derives and codegen consumes is a field on it.
The pieces that cross the analyze → codegen boundary:

### Per-node arrays (indexed by AST node id)

| Field            | Meaning                                                          |
|------------------|------------------------------------------------------------------|
| `ntype[id]`      | Inferred `TyKind` for the node. Read via `comp_ntype(c, id)`, the type cache codegen consults instead of re-inferring. |
| `nscope[id]`     | Owning scope index (`comp_scope_of`).                            |
| `node_cbody[id]` | Enclosing class/module-body class id, or -1.                     |

`comp_ntype` is the contract codegen relies on most: `infer_type`
(`src/analyze*.c`) fills `ntype[]` during analysis, and codegen reads it
back as the static type of every expression. (`TY_STRBUF`, a codegen-only
mutable-string storage refinement, is normalized to `TY_STRING` on read;
codegen consults the raw scope-local type where the distinction matters.)

### Scopes and locals

`scopes[]` holds one `Scope` per `def` / class method / lambda / block
body plus the top-level scope (`scopes[0]`). Each `Scope` carries its
parameter list, inferred return type (`ret`), yield/block metadata, and a
`LocalVar[]` of params + body locals with their inferred `type`. Codegen
emits C function signatures, local declarations, and call dispatch
straight from these.

### Program tables

`classes[]` (ivars + types, attr readers/writers, prepend chains, value-type
flag, `compiler_state` fields, …), `consts[]`, `gvars[]` (+ aliases),
`symbols[]` (intern table), `toplevel_includes[]`, and the FFI registry
(`ffi_funcs` / `ffi_consts` / `ffi_bufs` / `ffi_readers` / `ffi_libs` /
`ffi_cflags`). These are queried through the `comp_*` accessors declared
in `compiler.h` (`comp_class_index`, `comp_method_in_chain`,
`comp_reader_in_chain`, `comp_resolve_alias`, …).

Feature gating (which runtime helper blocks to emit, the class-machinery
tables, the `main()` prologue) is not stored as `@needs_*` flags the way
the legacy IR did; codegen recomputes it from the analyzed program via
scan passes (`scan_prologue_features`, `program_needs_class_machinery`,
…) immediately before emission.

## What analyze does

`analyze_program(c)` registers the program's declarations, then runs type
inference to a fixpoint and fills the per-node type cache. Conceptually:

1. **Collect** -- walk the AST registering classes, modules, methods,
   constants, ivars, globals, and FFI declarations into the tables above
   (`walk_scope` and friends in `src/analyze_scope.c`).
2. **Infer to fixpoint** -- iterate the inference passes
   (`src/analyze_infer.c`, `src/analyze_pass.c`): return types, ivar
   types from writers, parameter types narrowed from bodies, poly
   locals/params, hash/array variant selection, bigint loop promotion,
   etc. The loop repeats until the derived types stop changing.
3. **Finalize** -- post-fixpoint refinements (value-type detection,
   nullable re-narrowing, live-method marking) and then fill `ntype[]`
   for every reachable node so codegen reads cached types.

Because the two phases share memory, codegen can also call `infer_type`
directly for the few nodes whose type is context-dependent at emit time
(block-body expressions whose iterator-derived param types are not
pre-cached, `super` arms that need the current class). The cache covers
the overwhelming majority; these are the deliberate exceptions.

## Adding analysis state

Add a field to the relevant struct in `src/compiler.h` (`Compiler`,
`Scope`, `ClassInfo`, …), populate it in the analysis pass that derives
it, and read it in codegen. There is no serializer to update, no encoding
to round-trip, and no IR fixpoint to keep stable -- the value is just a
struct field both phases see. Verify with `make check` (test) plus
`make optcarrot` / `make bench` when the change touches type inference
(see [the gates](../README.md)).

## See also

- [docs/AST.md](AST.md) -- the `NodeTable` the analyzer and code generator
  both read, and its `--dump-ast` text form.
- `src/compiler.h` -- the `Compiler` / `Scope` / `ClassInfo` structs and
  the `comp_*` accessor API.
- `src/analyze.h` -- `analyze_program` / `infer_type` entry points.
