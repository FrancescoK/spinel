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

The contract is that analysis decides what each value is and what each
call does, and codegen prints it. (Which runtime helpers and tables a
program needs is the exception: codegen's scan passes recompute that just
before emission, under "Program tables" below.) Analysis fills the tables
below and, from them, the layers that answer codegen's questions: `repr_of` for how a value is laid out, the call plan and the
builtin-op rows for what a call does, the class facts for which classes
a value can hold. [architecture.md](architecture.md) lists every layer,
its entry points, and how a change that bypasses one looks in a diff.
The tables are what those layers are built from; an emitter that reads
a table to decide for itself is the old way.

> **Historical note.** The retired Ruby self-host ran analysis and
> codegen as separate binaries joined by a text `.ir` file. The C rewrite
> folded both into one binary; `src/compiler.h` notes that `Compiler`'s
> field set corresponds to the legacy `.ir` dump.

## The shared object: `Compiler`

`src/compiler.h` defines `Compiler`. Everything analysis derives is a
field on it, or in a layer built on it:

### Per-node arrays (indexed by AST node id)

| Field            | Meaning                                                          |
|------------------|------------------------------------------------------------------|
| `ntype[id]`      | Inferred `TyKind` for the node, read via `comp_ntype(c, id)` and written only through `comp_set_ntype`. |
| `nscope[id]`     | Owning scope index (`comp_scope_of`).                            |
| `node_cbody[id]` | Enclosing class/module-body class id, or -1.                     |

`infer_type` (`src/analyze*.c`) fills `ntype[]` during analysis: the
Ruby type each expression settled on. It is an input to the layers, not
a decision codegen should make from. How the value is laid out is
`repr_of`'s answer, and which emitter, builtin, method or arm a call
takes is the call plan's and the builtin-op rows'. Codegen still reads
`comp_ntype` in many places; those reads move to the layers as each
emitter is converted, and a new one is a finding unless the type is
itself the data, such as a class name in a diagnostic.
(`comp_ntype` also normalizes `TY_STRBUF` to `TY_STRING`; that storage
refinement is left from the two String representations (#9258) and goes
with the rest of them.)

### Scopes and locals

`scopes[]` holds one `Scope` per `def` / class method / lambda / block
body plus the top-level scope (`scopes[0]`). Each `Scope` carries its
parameter list, inferred return type (`ret`), yield/block metadata, and a
`LocalVar[]` of params + body locals with their inferred `type`. The
representation of each local is `repr_of_slot`'s answer (`repr_of_ivar`,
`repr_of_cvar` and `repr_of_ret` for ivars, cvars and return values).

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

`analyze_program(c)` (`src/analyze.c`) runs a fixed sequence of phases,
each named in an `AN_PHASE` line, so `--timing` reports them one by one:

1. **Collect.** Desugaring and the class structure register classes,
   modules, methods, constants, ivars, globals and FFI declarations into
   the tables above, then blocks are inlined and the pre-fixpoint passes
   run.
2. **Class facts.** `an_cls_facts` decides once which classes each value
   can hold, from the program's shape; the fixpoint's binding of a boxed
   receiver's call reads it.
3. **Infer to a fixpoint.** The inference passes (`src/analyze_infer*.c`,
   `src/analyze_pass.c`) repeat until no type changes:
   [fixpoint-convergence.md](fixpoint-convergence.md) covers the round
   count and the cap.
4. **Settle.** The post-fixpoint phases (procs, method backstops, late
   widening, storage, value types) and reachability.
5. **Seal.** `repr_seal` makes the representation flags final; after it
   `repr_of` is a pure read. Analysis then types once each block body
   that codegen emits per poly arm (`an_arm_facts`).

The call plan is resolved per call node on request (`cplan_user`), from
the settled facts. It is memoized only while the node is read as itself:
under a view, a moved scope, an `instance_exec` class or an inline
splice, it is resolved fresh and not kept.

A new pass is a new phase in that sequence, not a loop appended to
another one.

Codegen still calls back into inference in a few places (`infer_type`,
`infer_call`, `an_builtin_answer`) where analysis has not handed over
the type it needs. Each one is a fact a layer should carry; they are being retired,
and a new one is the old way.

## Adding analysis state

First find the layer that owns the fact in
[architecture.md](architecture.md). It is usually a row, the call plan,
`Repr`, a value-position walker or a name predicate, not a new field
codegen reads directly. When the fact does need new state:

- put it on the struct it describes in `src/compiler.h` (`Compiler`,
  `Scope`, `ClassInfo`, …) or in the pass's own context, not in a `g_*`
  global;
- write the tables `infer_type` reads only through their setters
  (`comp_set_ntype`, `lv_set_type`, `ivar_set_type`, …), which
  `make ty-setter-check` enforces;
- derive it in a phase of `analyze_program`;
- have the layer that owns the question answer from it, so codegen asks
  the layer.

A fact that holds for one emission only (one poly arm, one re-entry) is
a view, not analysis state ([architecture.md](architecture.md), "Views").

Verify with `make gate`; see [the README](../README.md).

## See also

- [architecture.md](architecture.md) -- the layers codegen asks, their
  entry points and their verifiers.
- [docs/AST.md](AST.md) -- the `NodeTable` the analyzer and code generator
  both read, and its `--dump-ast` text form.
- `src/compiler.h` -- the `Compiler` / `Scope` / `ClassInfo` structs and
  the `comp_*` accessor API.
- `src/analyze.h` -- `analyze_program` / `infer_type` entry points.
