# Constant keys and slots from the load record

Part of #9898. This is the constant half of retiring the qualify passes: value
constants get their C key (`cst_<key>`) and their slot from the load record's
constant entities, after the walk, instead of from strings before it.

- Probe table: `TABLE.md` (CRuby / master inline / master graph at the sha it names); `./run.sh <spinel>` re-runs it.
- Corpus measurements in section 2 were taken at master `b74120805` with a throwaway probe (a local patch, not on any branch) over `--dump-load-record` of every corpus program (9,602 programs). Function sizes and counts below were re-read at `94288ce9b`.

## 1. What names and registers constants today

### 1.1 Pass order (`an_phase_desugar_register`)

| step | what it does to constants | keyed by |
|---|---|---|
| lowerings | `desugar_const_set_write`: a literal `const_set(:N, v)` becomes `N = v` / `M::N = v`. `desugar_table_loops` runs on graph tables only, and its loops' `const_set`s become writes. `desugar_root_scoped_constants`: `::X` becomes `X`, marked `root_anchored` | node shapes |
| `qualify_colliding_consts` (53 lines plus helpers) | collects every ConstantWriteNode, and top-level path writes (`qc_note_path_write`, which stamps `qc_owner`), with its lexical module path. A write collides when its leaf is written under two or more paths, is nested and named like a builtin class, or is nested and shares a class leaf written elsewhere. Then `qc_rewrite_reads` renames each read to the qualified write it resolves to, `qc_keep_orig_name` stamps `qc_orig_name`, nested writes are renamed `Path__Leaf`, and `qc_const_quals` lists them | strings, whole tree, before the walk |
| `qualify_colliding_classes` (140 lines) | renames class headers and class references. It reads the constant half's decision through `qc_const_qualified` and the list of writes left bare | strings, before the walk |
| `elab_program` (the walk) | the record keys each write by `(owner, lr_written_name)`, the written name through `qc_orig_name` / `qc_ruby_name`, so the record is already blind to the renames | owner entity + written leaf |
| `register_structs` | builder classes by the write's (renamed) name | renamed name |
| `register_globals_consts` | `comp_const_intern(name)` by each node's current name; sets `const_def_write`, `init_guarded` and the regex type | renamed name |
| `rewrite_const_alias_receivers` / `_raise_targets` | rename class-alias reads (`A = Foo; A.bar`) to the class name (class references, not value slots) | name |
| `an_const_presence` | `elab_const_first_write(name)` over the record's slot index (`lr_slot_index`), indexed by the current lowered names | renamed name |

Nothing reads the value-constant table during the walk: `c->consts` is empty
until `register_globals_consts`, and the walk's constant reads go through
`lr_written_name`. That is what lets naming move after the walk.

A write the walk itself makes (a class-body macro's `const_set`, a table
loop once it is a walk form) is seen by neither pre-walk pass, so it can get
neither a key consistent with the others nor a slot. This is why the
class-body macro constants and the table-loop constants wait for this work.

### 1.2 Consumers of the renamed names (`94288ce9b`)

| fact | readers outside qualify |
|---|---|
| renamed `name` on value writes and reads | `comp_const(c, name)`: 116 call sites. `cst_%s` emission: 60 lines in codegen*.c. The record's `lr_const_slot_name`. Key-suffix matching: `comp_const_tail_cands` (6 refs) / `comp_class_owned_const` (5) |
| `qc_orig_name` (20 refs) | `lr_written_name`, the `const_node_class_index` carve-out, `const_value_owned_key`, analyze_desugar.c and codegen_call.c readers |
| `qc_owner` (7 refs) | `const_value_owned_key`, analyze_desugar.c, codegen_call.c |
| `qc_ruby_name` (10 refs) | the class half's; not this work |
| `qc_const_qualified` / `qc_leaf_qualified` (4 refs each) | the class half and analyze_util.c |

At `b74120805`, 207 corpus programs (67 tests, 140 package programs) carried
a qualified constant key in their C, with 336 distinct qualified keys.

## 2. Measurements (corpus, `b74120805`)

### 2.1 Write keys from entities

The rule, applied to the record's histories, is qualify's own:
- a top-level owner (main / Object) keeps the leaf;
- a nested write keeps the leaf unless the leaf is written by another value entity under another owner path, is a builtin class name, or is the leaf of a class entity under another path;
- otherwise the key is the owner's Ruby path (class entities' leaves, owner by owner) joined by `__`, then `__` and the leaf.

Writes with an unknown owner (a run-time `const_set`) take part in no
collision, since qualify never sees them.

Result: 5,565 programs with constants, 16,883 statement-level value writes,
**16,878 with the same key**. The other 5:

| program | qualify's key | record's key | cause | handling |
|---|---|---|---|---|
| test/compact_class_alias_head_scope.rb | `Object__A12` (`class Object; A12 = P12; end`) | `A12` | qualify takes `class Object`'s body as a path; it is the top level | naming-only C change, same output |
| test/compact_path_builtin_parent_const_reads.rb (2 writes) | `Syntax__V1_9_1__PROPS` | none | no entity for `class Regexp::Syntax::V1_9_1`: the record cannot resolve a path through the builtin parent | the header gets its entity (owner `Regexp::Syntax`, no path segment for the builtin), in PR 1 |
| test/const_path_write_struct_data_holder.rb (2 writes) | `Tex__WHITE`, `Grid__SIZE` | `WHITE`, `SIZE` | the record does not know a blockless `Color = Struct.new(...)` as a class, so `Color::WHITE = ...` has an unknown owner | **prerequisite** (section 4.0); without it the two writes merge, a regression |

### 2.2 Reads

For every constant read in value position that names a value slot, the
probe asked the record for the write it resolves to
(`elab_const_at`, or `elab_class_ref_at(parent)` plus `lr_const_in`) and
compared that write's key with the read's key.

| model | reads | agree | **disagree** | not bound (NO) | unknown | resolves to a class header |
|---|---:|---:|---:|---:|---:|---:|
| inline | 27,675 | 27,210 | **0** | 159 (69 programs) | 304 (120 programs) | 2 |
| graph | 27,695 | 27,168 | **0** | 162 | 363 | 2 |

Only 25 unresolved reads (6 programs) carry a key qualify renamed:

| reads | program | cause | handling |
|---:|---|---|---|
| 7 | const_set_receiver_scope | the history is `may` only because a later method-body `const_set` exists; the entity is certain | the entity query separates "which entity" from "bound yet" (3.2) |
| 4 | sqlite3_basic | the parent is written `may` (inside a guarded require); it is the only candidate | the same split for path parents |
| 2 | const_path_write_beside_toplevel, const_leaf_shared_with_class | qualify's own bookkeeping: the ancestor branch of `qc_rewrite_reads` renames a path read without keeping the original name, so the record is asked for `Base3__LIM` | gone with qualify: the read keeps `LIM` and resolves |
| ~10 | the two programs of 2.1 | the two write gaps | PR 1; the prerequisite |

The other NO / unknown reads keep their written name today and after:
reads CRuby rejects, `defined?(::Version)`, record gaps where qualify's flat
key happens to answer (a `module Kernel` constant read at the top level, a
constant of a module mixed in by `Object.include`), reads through builtin or
native parents (`Encoding::UTF_8`, OpenSSL constants), and may-writes
(`X = 5 if ...`, `F ||= ...`).

## 3. The target

### 3.1 What the record holds per constant entity

- **The entity is the history** that already exists, keyed `(owner, leaf)`:
  `owner` is a class entity, main, or a singleton owner; an unknown owner is
  not an entity. Its versions are the writes, with point, `may` and `nil`
  flags. Nothing new is recorded per write.
- **New in `LoadRecord`:** an entity index over those histories (owner, leaf,
  history, and the key once computed), and the write node -> entity map, a
  hash beside the node -> class map filled when the write is recorded, so a
  walk-made write is in it the moment the walk records it. No new global and
  no file-scope table.
- **Owner paths** come from class entities, owner by owner up to main. A
  builtin owner contributes no segment, as `qc_header_segs` drops it today.

### 3.2 Queries

- `elab_const_entity_at(c, node, cands, max)`: the entity or entities a
  constant read can name at its point. It is `lr_const_at` / `lr_const_in`'s
  walk with "which entity" separated from "bound yet": a history with a write
  before the point answers; a history whose writes before it are all `may`
  adds itself as a candidate and the walk goes on. Path parents use the
  candidate classes. Answers: one entity, several, none (NO), or unknown.
- `elab_const_key(c, entity)`: the key (3.3).
- `elab_const_write_entity(c, node)`: the map. It replaces `qc_owner` at its
  readers, and it is the home of a public (class, name) -> entity query.

### 3.3 Keys

- The rule is qualify's (2.1), run once after the walk over the whole index,
  with leaves bucketed in a hash.
- Spellings stay qualify's: Ruby leaves joined by `__`, which
  `comp_class_owned_const`'s suffix match and `const_value_owned_key` rely on.
- A singleton owner keeps today's spelling (its class's path) unless it
  collides with its class's constant of the same leaf; then
  `<path>__singleton__<leaf>`. A lowercase segment cannot be a Ruby constant,
  so it cannot collide. Corpus: 0 such programs.
- Inline C is identical except for the listed programs. This holds by
  measurement, not by construction, because the inputs differ (lexical paths
  vs entity owners); re-running that probe is the first PR's review evidence.

### 3.4 A walk-time `const_set`

The class-body macro form splices `NAME = value` (or `M::NAME = value`) at
the call through `host_splice`. The walk records it like any written
constant, so it is in its history and in the write map. Naming runs after the
walk, so it is keyed with everything else: two macro-made `SIZE`s in `Calc`
and `Small` become `Calc__SIZE` / `Small__SIZE`, the keys the inline text
expansion plus qualify give today. Its reads resolve through the record.

### 3.5 End state

Codegen and analysis ask `comp_const_at(c, node)`, the slot of the entity the
node names; `cst_<key>` comes from the slot. No constant node is renamed;
`qc_orig_name` / `qc_owner` for constants and `lr_const_slot_name` go.
`comp_const_tail_cands` / `comp_class_owned_const` become an own-constant
query on the receiver's class. A read the record cannot bind raises
NameError, CRuby's answer, once the record gaps close.

## 4. Steps

### 4.0 Prerequisites

- **Blockless builders as record classes.** `Point = Struct.new(:x, :y)` and
  `Data.define` without a block: `lr_class_of` answers unknown today
  (`const ?::WHITE` in `--dump-load-record` for `Paint = Data.define(:name);
  Paint::WHITE = 1`, re-checked at `94288ce9b`). Without the entity,
  `const_path_write_struct_data_holder.rb`'s `Color::WHITE` merges with
  `Tex::WHITE`. This is a record fact about class builders.
- **`Object::Y = v` owned by main** (`#10774`): the record writes `?::Y`.
- Merged already: the `const_get` family naming its receiver by class id
  (#10693), the class table indexed by def node with the plan's frame
  (#10696), and a class alias held in a module as a receiver (#10666).

### 4.1 PR 1: constants are named from the load record after the walk

- **c1, record gaps the keys need:** the entity of a header under a builtin
  compact path (`class Regexp::Syntax::V1_9_1`, owner `Regexp::Syntax`, no
  segment for Regexp); the write map (3.1).
- **c2, keys:** `elab_const_entity_at`, `elab_const_key`, keys computed once
  at the end of `elab_program`. The slot index keeps reading names, which are
  now the entity keys.
- **c3, the carrier:** right after `elab_program`, each write gets its
  entity's key and each read the record resolves gets its entity's key; an
  unresolved read keeps its written name; an unknown read whose candidates
  have differing keys takes the innermost (qualify's answer). Renames are
  queued and applied after the last ask, so no ask sees an edited table and
  the point map is built once.
- **c4, qualify's constant half goes:** `qualify_colliding_consts`, the
  constant renames, `qc_note_path_write`'s rename side, `qc_const_quals` and
  `qc_keep_orig_name`'s constant callers. The class half's two inputs get the
  collision test as a static helper inside the class half, which dies with
  it; `SPINEL_ELAB_CHECK` asserts the post-walk key equals that helper's
  decision for every write. `qc_owner`'s readers ask `elab_const_write_entity`.
- **c5, tests:** the singleton-class, nested-path and read-before-shadowing
  shapes (probes a2, a3, a8) with CRuby's `.expected`; a reopened-class
  collision; a graph pair under `test/load_graph` (a constant in a required
  file colliding with the main file's); the scale program (section 6).

Size: about +250 / −180 in src; qualify loses ~150 lines. The shared read
rewrite (`qc_rewrite_reads`, `qc_alias_chain`) stays for the class half.

One risk to measure in review: today the constant half renames value reads
before the class half runs, which keeps `qc_rewrite_reads` from matching a
read that a nested value constant shadows. Without it the class half may
rename such a read toward a class; c3's stamp then overwrites it. The check
mode reports each read whose name the class half changed and the stamp
overwrote, and the review counts them.

### 4.2 PR 2: slots registered from the record's entities (~250)

`register_globals_consts`' constant branch iterates entities: one slot per
value entity, with `const_def_write` / `init_guarded` / the regex type from
its writes; the slot index per entity (`lr_const_slot_name` goes);
`an_const_presence` per entity. It keeps first-write order, so C should be
byte-identical. The `A::B::C = remove_const(:C)` form
(`desugar_constant_path_self_alias`, ~34 lines) folds in here as a constant
write of the removed value at its point.

### 4.3 PR 3a-3c: constant slots by node (3 × ~300)

- 3a: `comp_const_at(c, node)`; the analysis consumers (~55 of the 116); the
  `const_value_owned_key` / `comp_class_owned_const` callers. Its
  analyze_util.c part goes together with converting `const_path_scope` /
  `const_node_class_index` on the class side (the same functions).
- 3b: the codegen consumers (~60) and the 60 `cst_` lines print the slot's key.
- 3c: the carrier goes; `qc_orig_name` / `qc_owner` for constants go;
  `lr_written_name` shrinks to the class half's.

Byte-identical by construction. 3a needs stable record answers while passes
rewrite between asks (the plan frame of #10696).

### 4.4 PR 4: a constant the record cannot bind raises NameError (~150)

After the record gaps of section 8 close. Answer changes, listed.

## 5. Answer changes (probes; CRuby / master inline / master graph)

| probe | CRuby | inline | graph | after PR 1 |
|---|---|---|---|---|
| a2 `class << self` constant | 1 2 1 | 2 2 2 | 2 2 2 | CRuby (separate entities). Corpus: 17 programs have singleton-class constants; 0 share owner and leaf |
| a3 nested `N::X = 1` beside a top-level X | 1 2 3 3 | 2 2 3 3 | 2 2 3 3 | CRuby (owner N). qualify notes path writes at depth 0 only; 5 corpus programs have nested path writes |
| a8 `Y = X` before `X = 2` in a class | [1, 2] 1 | NameError | NameError | CRuby: the record resolves Y's read at its point. 0 corpus programs |

Kept: every other probe in the table (controls for collisions, builders,
ancestors and `defined?`). a5 (an Array loop calling `const_set`) stays
refused in both models: neither a table loop nor a macro. a6 (a Hash table
loop) is the table-loop work's.

## 6. Cost and scale

- Keys: one pass over the entity index with leaves bucketed in a hash, O(E).
  Today's constant half compares every write with every other and resolves
  each read against the write list per lexical scope.
- The stamp: one entity query per constant read, O(lexical depth + ancestor
  chain). Renames are queued, so the point map is built once; no ask may
  rebuild the record (the trap `rewrite_const_alias_receivers` documents and
  `test/scale/alias_receivers.sh` guards).
- Walk-made writes enter the index when recorded; naming runs once after the walk.
- New scale program `test/scale/const_collisions.sh N`: N classes, each
  writing `SIZE` and reading it lexically, from a method and by path;
  compiled at 400 and 800, limit 2.20. It fails if an ask rebuilds the record
  or the collision pass goes quadratic.

## 7. Checks per PR

Each PR: cident with its list explained (PR 1: compact_class_alias_head_scope
naming only, the a2 / a3 / a8 shapes, the 5 nested-path-write programs, and
anything the class-half interaction adds); a graph run with no pass turning
into a failure; new tests plain, under `--int-overflow=promote` and under
`SPINEL_GC_STRESS=1`; scale-test. PR 1's review also re-runs the read probe:
0 disagreements, and the unresolved count no worse.

## 8. Not covered (master has the same)

- a5: an Array loop calling `const_set` with computed names in a class body
  is refused in both models.
- Record gaps PR 4 waits for, each answered today by qualify's flat key:
  constants of `module Kernel` read at the top level or in classes; constants
  of a module mixed in by `Object.include M`; reads through native or builtin
  parents (`Encoding::UTF_8`, OpenSSL::SSL constants).
- Unknown reads whose candidates have differing keys (an inner may-write):
  CRuby decides at run time. PR 1 keeps qualify's innermost choice; a run-time
  presence select is possible later (`cst_X__set` exists).

## 9. Open questions (with our recommendation)

1. **Keys written on nodes after the walk (PR 1) before the node-keyed API
   (PR 3).** Recommended: yes. It deletes the pre-walk string pass now and
   unblocks walk-made constants with ~380 lines; the carrier dies in 3c. The
   alternative, the 116 + 60 conversions first, holds walk-made constants
   behind ~1,000 lines.
2. **PR 1's answer changes (a2, a3, a8).** Recommended: take CRuby's answers
   with tests. They fall out of entity keys; keeping master's answers would
   need new code that merges distinct entities.
3. **Unresolved reads keep their written name in PR 1; NameError waits for
   PR 4.** Recommended: yes. It is qualify's identity for unmatched reads, so
   it adds no wrong answer; raising now would regress the record-gap cases.
4. **An unknown read with candidates of differing keys takes the innermost.**
   Recommended: yes, as qualify does, listed under Not covered.
5. **A singleton-class constant colliding with its class's constant** is
   spelled `<path>__singleton__<leaf>`, only on collision. Recommended: yes.
6. **The class half keeps a copy of the collision test until it goes**, since
   `qualify_colliding_classes` runs before the walk and cannot ask the record.
   Recommended: accept it as the class half's own input, deleted with it, with
   `SPINEL_ELAB_CHECK` asserting agreement with the record's key for every
   write.
