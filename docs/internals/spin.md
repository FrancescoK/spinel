# spin packages & spin — design

The design record for Spinel's package system (**spin packages**) and its
project tool (**`spin`**). The user-facing guide is [../spin.md](../spin.md);
this document is the *why* and the *contract*: the constraints, the
requirements (R1–R10), the resolution semantics, and what remains open.

Naming note: the tool is **`spin`**, the manifest **`spin.toml`**, the
lockfile **`spin.lock`**, the unit a **package**, and the registry
[spin-index](https://github.com/matz/spin-index). "Gem" was dropped
deliberately: the mechanism shares nothing with RubyGems (no gemspec, no
runtime require, no tarballs -- sources splice into one AOT compile), and a
Ruby-evocative unit name invited expectations of compatibility the design
cannot honor. Published *repos* stay `spinel-<name>` -- that convention is
scoped to the language, like `mruby-*`.

Status: implemented through M3 — scaffold, path/git/index dependencies with
MVS selection, `spin.lock`, vendor + offline, snapshot tests, carried native
C, declared native build steps (R10), the flags handoff and `[package]
exclude` (R11), `list`/`tree`/`search`. The hermetic
end-to-end check (`tools/spin_e2e.sh`) runs inside `make check`. Sections below note the
pieces that are still specification.

## 1. Problem

External libraries used to live as `.rb` files under `lib/`, side by side
with the C runtime (`sp_*.c/h`) and the bundled stdlib. Consequences: no
boundary (what is runtime, stdlib, or replaceable library?), no identity
(no name, version, or dependency declaration), no sharing (installing a
library meant copying files into the compiler tree).

## 2. Reference points

**RubyGems/Bundler** gives the *consumer model* worth copying: a per-project
manifest, a lockfile, a flat namespace, and `require "name"` as the only
thing consumers write. Its *mechanism* (runtime `require` onto a load path,
dynamic .so extensions, install-time code execution) does not fit AOT.

**mrbgems** gives the *producer model* worth copying: a package is a source tree
compiled *into* the final binary, with a small spec. Its consumer model
(gems baked into the VM per toolchain) does not fit either: Spinel
dependencies are per-application.

Spinel wants **RubyGems' per-app consumer surface on mrbgems'
compile-into-the-binary producer model.**

## 3. Constraints peculiar to Spinel

- **C1 — whole-program AOT.** All sources are known at compile time;
  `require` is textual splicing. Packages are *source* inputs to the one
  compile: inference specializes a package's code per application. There is
  no binary package artifact and no ABI.
- **C2 — subset language.** Not every package compiles under Spinel.
  Compatibility is a first-class, testable property (the ~189k-gem probe
  corpus), not a footnote.
- **C3 — C is reachable two ways.** FFI (`ffi_lib`/`ffi_func`) to external
  libraries, and carried C inside the package tree. The runtime headers stay
  additive-only; package C must not mutate runtime internals.
- **C4 — the strict-require is the resolution point.** `require "name"`
  already resolves bundled stdlib, native features, and `-I` roots, and
  gates typed surfaces on it. Packages are one more provider behind the
  same gate — not a second mechanism. Inside a `spin` project the gate is
  strict (`SPINEL_STRICT_REQUIRE=1`): the dependency universe is fully known,
  so an unresolvable `require` is a hard error, and stdlib features need
  their `require` just as in CRuby.
- **C5 — types cross package boundaries.** Inference runs over the spliced
  whole program; a package's poly-dispatch arms must be instantiation-gated
  by what the *application* constructs (open work), and a package may pin
  its public surface with `.rbs` sidecars.

## 4. Requirements

### R1 — separation of layers

| layer | contents | ships with | user-visible? |
|---|---|---|---|
| runtime | `sp_*.c/h`, archives | the compiler | never edited, not require-able |
| stdlib | require-only features (`set`, `erb`, `json`, …) | the compiler | via `require`, no manifest entry |
| packages | everything else | fetched/vendored per project | via `require` + manifest entry |

The boundary is directory-level and implemented: `lib/` holds runtime C
only, and the bundled pure-Ruby stdlib (`set`, `erb`, `optparse`,
`forwardable`, plus the `stringio`/`strscan` marker shims) lives as
pre-installed packages under `packages/<name>/` -- each an ordinary package with
a `spin.toml`, proving the format on the compiler's own stdlib. The
compiler resolves `require` against `packages/` beside its runtime (repo and
installed tree alike, through symlinked invocation). Packages-only
directories: `packages/<name>/` (pre-installed),
`vendor/packages/<name>-<version>/` in a project,
`$XDG_CACHE_HOME/spin/packages/<name>-<version>/` for fetches.

### R2 — package format (implemented)

A package is a directory, typically a git repo named `spinel-<name>` by
publishing convention; the package *name* carries no prefix because the name is
the `require` string. There are no per-language role directories: **role is
carried by extension and the package root is the require root**. `.rb` compiles
and defines the require namespace (`mypkg.rb`, subfeatures under `mypkg/`),
`.rbs` is an optional sidecar, `.c`/`.h` are carried native sources (R6).
Reserved directory names, excluded from the require namespace: `test/`,
`bin/`, `build/`, `vendor/`.

**Executables.** Each `bin/<name>.rb` is an executable and its own
whole-program compile root, spliced with the package's library sources and
resolved dependencies (cargo's `src/bin/*.rs` shape). **An application is a
package with executables** — same manifest, no separate project kind, and the
`[package]` identity table is optional for applications (name defaults to the
directory basename; publishing is what makes identity mandatory).
Dependents of a package never compile its `bin/`.

**Tests.** Each top-level `test/*.rb` is one test program through exactly
the `bin/` mechanics. Pass/fail is the compiler-repo oracle convention: a
committed `.expected` snapshot diffs against stdout; with no snapshot the
same file runs under `ruby` and diffs directly — the subset-parity check.
`spin test --regen` refreshes snapshots. Subdirectories of `test/` hold
`require_relative` helpers, not entries.

**Manifest** (`spin.toml`) is TOML and never executable: fetching or
vendoring a package runs no package code, and compilation of package C happens only
while building a dependent application. Implemented fields: `[package]
name`/`version`, `[dependencies]`, `[[build]]` + `[native] libs` +
`[features] default` (declared native build steps, R10). *Still
specification:* `[dev-dependencies]`, `provides` (feature names beyond the
package's own), `spinel` (compiler version constraint — reserved until the
toolchain is versioned), `[native]` cflags and bare `-lLIB` entries (carried
C needs no manifest entry; external installed libraries use the `ffi_lib`
DSL in the Ruby source), and `[build] spinel-flags`.

### R3 — consumer surface (implemented)

- `spin.toml` declares dependencies; sources are an index constraint string,
  `{ git = URL[, ref = R] }`, or `{ path = DIR }`.
- `spin.lock` records the machine-resolved result: exact versions including
  transitive dependencies, full commit SHAs for git/index sources.
  Reproducibility matters more than in CRuby: under whole-program inference
  a dependency bump can change whether the application *compiles*.
  Applications commit it; libraries do not. Absent a lock, builds resolve
  from the manifest (deterministic — see R5/MVS).
- In code, consumers write `require "name"` — nothing else. Resolution
  order: runtime-native feature → stdlib → project packages → `-I` roots.
- The zero-manifest escape hatch stays: hand-written `spinel -I` invocations
  have identical semantics; a manifest is only needed for
  versioned/fetched dependencies.

### R4 — resolution & versioning semantics

- Flat namespace; **one version of a package per application** (two copies of
  the same classes are a whole-program conflict, not an isolation feature).
- The dependency graph is walked transitively (a fetched package's own
  `[dependencies]` resolves too) and must be acyclic.
- *Still specification:* feature-namespace ownership enforcement (two packages
  providing overlapping features as a named resolution error), and
  undeclared-cross-package-require checking below resolution granularity — the
  latter needs per-root provenance that plain `-I` does not carry, layered
  on top of `-I` when it moves into the compiler.

### R5 — distribution (implemented through the index)

- **Phase 1: no registry.** Local paths + git URLs pinned by the lockfile
  SHA. `spin vendor` copies the resolved tree into `vendor/packages/`;
  `SPIN_OFFLINE=1` builds from cache/vendor only. Vendored trees are
  read-only inputs.
- **Phase 2: an index, not a server** (implemented): a git repository —
  <https://github.com/matz/spin-index> by default, `SPIN_INDEX`
  overrides, `file://` works — mapping names to repos and releases. One
  TOML file per package, read by the same reader as `spin.toml`:

  ```toml
  # packages/<name>.toml
  name = "ansi"
  repo = "https://github.com/x/spinel-ansi"

  [[release]]
  version = "1.2.0"
  ref = "a94a8fe5cc..."   # full commit SHA in `repo`
  ```

- **Name policy**: same name as a rubygems.org gem means "the same library,
  possibly a subset-compatible port"; divergent forks rename
  (`foo-spinel`). Name reservation is the first accepted publish PR; the
  gate is review and sign-off, with no popularity floor and no tier
  requirement. Candidate/roadmap records (the probe corpus) stay OUTSIDE
  the index -- compat.jsonl is the sidecar; the index carries only
  fetchable packages (decided on #1753).

  **Mirrors** — a package reimplementing a gem's consumer surface in the
  subset rather than porting its source — may claim the gem's require
  string under three normative conditions (the require string is the
  consumer surface being honored):
  1. *Ledgered divergences*: a documented exclusion ledger of what was
     narrowed;
  2. *The real gem as oracle*: the claimed surface is verified
     differentially against CRuby plus the real gem;
  3. *Loud failure outside the contract*: out-of-ledger surface fails
     visibly (ideally at compile time), never silently diverging.
  These mirror the compiler's own rule (unsupported constructs raise and
  are documented): the name is honest exactly as long as everything behind
  it either matches CRuby or refuses loudly. spinel-redis is the reference
  shape (oracle/ harness + README ledger).

  **Replacement**: names are held by evidence, not by arrival.
  - *Holding*: a name stays claimed while the package keeps conditions
    1-3 and its R8 probes pass at current engine revisions (a fail
    re-published within a reasonable window is fine).
  - *Staleness reclaim*: consecutive engine revisions with failing or
    absent probes plus an unresponsive maintainer make the name
    reclaimable via an index PR, with notice and a grace window (initial
    numbers, tunable: 2-3 engine revisions, 30 days).
  - *Superset challenge*: an actively-held name can be petitioned for
    only by measurement -- the challenger passes the incumbent's entire
    oracle suite plus more, with a strictly smaller exclusion ledger;
    ties and partial overlaps keep the incumbent.
  - All of this rides the ordinary PR flow and R8 records. `spin.lock`
    pins full SHAs, so a reassignment only affects new resolutions;
    locked builds never break.
- `spin publish` (implemented): validates identity + a pushed,
  version-consistent release commit, runs `spin test` as a hard gate (R8's
  spirit ahead of its metadata), then writes `packages/<name>.toml` and submits
  -- a gh-driven fork + PR when `gh` exists, printed instructions
  otherwise, or a direct push with `--direct` for index write access. The
  GitHub ssh remote form normalizes to https; file:// and local-path repos
  are refused (consumers must be able to fetch). Same-name/different-repo
  is rejected per the name policy. No tarballs, no accounts, no yank
  (removals are hand-written index PRs).

**Selection is MVS** (decided, implemented): among releases admitted by the
constraint (`~>` pessimistic, `>=`, exact, `*`), every package resolves to the
*lowest* admissible version.

- Deterministic without a lockfile — which is what makes `spin.lock`
  droppable for libraries instead of load-bearing.
- No SAT solving. Constraint gathering is first-encounter: a later
  conflicting constraint on an already-resolved package is an error, not a
  re-solve.
- Not auto-riding the newest release is intentional under whole-program
  inference; upgrades are opt-in and diffable.

Order of authority: `spin.lock` when it satisfies the manifest (a pinned
version that no longer satisfies a changed constraint is reselected with a
warning, and the next `spin lock` rewrites the pin); `vendor/packages/` then the
cache for sources; path deps always read live and are recorded unpinned.
Fetch materializes the exact release SHA — direct SHA fetch with a
full-clone + checkout fallback — and dies on mismatch. *Still
specification:* `spin lock --update` and `--frozen` (CI mode).

### R6 — C in packages (implemented)

- Carried C is **declared**: `[package] sources` names the `.c` files, as paths
  relative to the package root, globs allowed. They compile into the shared
  cache `$XDG_CACHE_HOME/spin/native/<package>-<version>-<cc>/` — never into the
  package tree — and the objects reach the compiler via its repeatable
  `--link` flag; `spinel` itself never compiles package C. Objects rebuild when
  a declared `.c`, or any `.h` in the tree, is newer; the package tree and the
  compiler's runtime headers are on the include path; `CC` selects the
  toolchain. No `sources` key means the package carries no C.
- The second shape, FFI to an external installed library, stays on the
  Ruby-side `ffi_lib`/`ffi_func` DSL (its SPINEL_LINK/SPINEL_CFLAGS markers
  already reach the link line). In-TU splicing of carried C is a possible
  future optimization behind the same declaration, not a third shape.
- **`[package] sources`** (implemented; #4362) replaced discovery by presence.
  The asymmetry it removes: **`.rb` entered the build by reachability
  (`require`), `.c` entered by presence.** For a library that read as R2
  working as intended — role by extension, nothing listed in the manifest —
  but presence is not a declaration. A file the author never meant as a source
  (a program of their own beside the Ruby, a scratch `.c` an agent left there)
  was compiled anyway, and its `main()` collided with the generated one; the
  diagnosis was a wall of multiple-definition lines naming symbols rather than
  the file. Both halves of a package are declared now. Globs are allowed
  because the author owns the consequence: `sources = ["*.c"]` is the old
  behaviour, and it picks scratch files back up.
  - A `.c` in the tree that no entry names is **reported**, not dropped
    quietly, and so is an entry that matches nothing. A forgotten declaration
    would otherwise arrive as an undefined symbol at link — the same "hard to
    figure out why" with the sign flipped.
  - The staleness scan follows: declared `.c` plus every `.h` in the tree,
    since headers are reachable by inclusion rather than declared. A scratch
    file nobody compiles no longer forces a rebuild.
  - Migration, measured before the flip: six in-tree packages (they move with
    the compiler), and of the external ones only spinel-bcrypt carries C — a
    branch-tracked git dependency, so one push. pg, redis and spinel_kit, the
    index-published packages, carry no `.c` at all.
- **`[package] exclude`** (implemented; #4105) prunes globs, relative to the
  package root, from what `sources` named and from the staleness scan that
  decides whether the cached objects are current. With declaration it is no
  longer the only way to keep a stray file out — it is what a glob needs, to
  subtract from what it reached. An excluded `.h` stays on the include path,
  being excluded from compilation rather than from inclusion. Globs are
  expanded at manifest-read time into the same exact-path list `[[build]]`
  workdirs already travel in, so naming a directory prunes its subtree.
- **Spinel emits over its own output only** (implemented; #4362). `-c -o P`
  refuses when P exists and does not open with the compiler's banner, since
  emitting there replaces a source with a translation unit and nothing
  downstream can undo that -- the rule below can only report that the file
  is gone. `--force` is the way through. This is the destructive half of
  the asymmetry; the rule below is the noisy half.
- **Spinel's own output is not carried C** (implemented; #4362). A `.c` whose
  first line is the compiler's banner is left out even when a `sources` glob
  reached it, and named on stderr. It defines `main` and, through the internal `spinel_rt.h`, a copy of
  the runtime's non-static surface, so compiling it collides with the generated
  TU on both -- and the collision reports symbols, never the file that brought
  them. The asymmetry above is what makes this reachable at all: one
  `spinel app.rb -c -o out.c` run inside the tree and the compiler's output IS
  the build's input. It is skipped rather than compiled, but reported rather
  than skipped quietly, since the file may have overwritten a source of the
  same name -- where silence would trade a wall of link errors for a single
  undefined symbol.
- *Still specification:* the `spinel/runtime.h` umbrella defining the
  stable public sp_ surface for carried C; today package C sees the same
  headers as the generated TU, with no compatibility promise on internals.

### R7 — type inference across packages

- Package sources are spliced and inferred with the application (C1); no
  pre-compiled types. `.rbs` sidecars pin public surfaces via the existing
  `--rbs` machinery. Diagnostics carry file:line positions through the
  `#line` machinery.
- *Open:* instantiation-gating of package-contributed poly-dispatch arms
  (an application that never constructs a package class should not pay for
  it — also the recovery path for the gate-flip's optcarrot cost).

### R8 — compatibility as metadata (implemented, SHA-versioned)

The toolchain version is the compiler's build revision — `spinel
--version` prints the git SHA embedded at build time — which unblocks R8
without deciding semver. Index package files carry flat `[[probe]]` records
(version, spinel = build SHA, result, detail, date): `spin publish`
appends a pass for the publishing build automatically (its hard test gate
just ran), and reprobe sweeps can append fails. Resolution surfaces them
before fetching: a fail recorded against the exact current build warns
"recorded FAILING with this compiler build", any newest-fail warns
generically, and neither blocks — the build is the final answer. Semver
toolchain constraints (`spinel = "~> x.y"` in the manifest) still await
real versioning.

### R9 — tooling: `spin`, a separate project tool (implemented)

The compiler CLI stays gcc-like: sources + `-I` roots in, binary out, no
network, no manifest knowledge, no state. `spin` owns everything stateful —
manifest editing, resolution, fetching, vendoring, invoking the compiler —
and every command works offline given a populated cache or vendor tree. No
daemon; no per-machine state outside `$XDG_CACHE_HOME/spin/`.

- `spin` is written in Spinel and ships beside the compiler (`make
  bin/spin`), dogfooding the language and the package format. Its dependencies
  are stdlib-only; its TOML reader (`tools/spin/toml.rb`, string-only
  storage, `[table]`/`[[table]]`/inline tables) is the intended seed of a
  future `toml` stdlib feature.
- Subcommands on the compiler CLI were considered and rejected: `spinel
  build` is ambiguous against `spinel build.rb`, and the compiler binary
  should not carry TOML/git/network code.
- Compiler interface: one `-I` per resolved package in resolution order, plus
  `-I <root>`, plus `--link <obj>` per cached native object, plus
  `SPINEL_STRICT_REQUIRE=1`. An unresolved-`require` compile error is wrapped
  with the `spin add` hint that would fix it.
- Known name collisions, accepted: Fermyon's wasm tool and the SPIN model
  checker also install `spin`; distro packages may need a `spinel-spin`
  package name even though the binary stays `spin`.

### R10 — declared native build steps (implemented; #1820)

A package vendoring an external project with its own build system (cmake,
make) — ggml is the driving case — cannot be expressed as carried C (R6's
per-file `CC` has no configure step, per-arch flags, or nvcc). `[[build]]`
declares the step instead of running arbitrary tasks:

```toml
[[build]]                        # repeatable (ggml + a shim archive = two)
workdir   = "vendor/ggml"        # read-only input; the build runs in a scratch copy
patches   = ["patches/*.patch"]  # applied to the scratch copy (patch -p1)
command   = "cmake -B . ... && cmake --build ."
artifacts = ["libggml.a"]        # verified after the run; missing = failure
features  = ["cuda"]             # optional gate; off unless in [features] default
exclude   = ["build*"]           # workdir globs pruned from the content key
                                 # and the scratch copy (a dev tree's own
                                 # build output must not ride the hash)

[native]
libs = ["${build.out}/libggml.a"]   # artifacts reach the R6 --link surface
```

- **When**: only while building a dependent application (`spin
  build`/`run`/`test`); `spin fetch`/`vendor` execute nothing, preserving
  R2. The same package works as the build root (its own `bin/`) and as a
  library dependency.
- **Consent, never silent** (deliberately unlike cargo's `build.rs`):
  `--allow-native-build` (one run), `SPIN_ALLOW_NATIVE_BUILD=1` (CI),
  `spin trust <name>` (recorded in `$XDG_CONFIG_HOME/spin/trust`), or —
  on an interactive terminal — an `Allow? [y/N/always]` prompt (`always`
  records the trust entry). A non-interactive build never waits on a
  prompt: it refuses with those options. A cached artifact skips consent —
  the consented command already ran on this machine.
- **Cache**: artifacts land in the shared native cache keyed by content
  (workdir tree hash + patch bytes + command + artifacts + toolchain +
  enabled features). A source or patch change moves the key and rebuilds;
  unchanged steps are reused across consumer projects with no
  build-system run.
- **Link**: `[[build]]` only *produces* artifacts. Linking stays on the
  existing surface — `[native] libs` entries, `${build.out}` expanded,
  flow into the compiler's repeatable `--link` (which accepts archives);
  R6 gains no third link shape. An entry whose artifact was
  feature-skipped drops out of the link line; a libs path that NO entry
  declares dies loud at build time (a stale path otherwise surfaces as
  undefined symbols at link).
- **Threaded programs**: a program that uses `Thread` links a runtime
  archive built with `-DSP_THREADS`, which makes the runtime's per-worker
  globals thread-local. A package object built without that flag reads
  them as non-TLS and the link fails, so a package whose C touches the
  runtime needs a second variant. The convention is a `_mt` suffix before
  the extension — `sp_json.o` / `sp_json_mt.o`, `libfoo.a` /
  `libfoo_mt.a` — and the compiler picks it up: for a threaded program it
  prefers `<stem>_mt.<ext>` beside every link input, and falls back to
  the plain one when there is none. Nothing has to be declared for the
  selection itself.

  One `[[build]]` entry produces both, since `command` is a shell command
  and `artifacts` is a list:

  ```toml
  [[build]]
  workdir   = "src"
  command   = """
    cc -c sp_json.c -o sp_json.o &&
    cc -DSP_THREADS -ftls-model=initial-exec -c sp_json.c -o sp_json_mt.o
  """
  artifacts = ["sp_json.o", "sp_json_mt.o"]

  [native]
  libs = ["${build.out}/sp_json.o"]   # name the PLAIN one; _mt is found beside it
  ```

  `[native] libs` names the plain variant only. Listing both would put
  both on the link line and the duplicate definitions would fail the
  link. `-ftls-model=initial-exec` matters for the same reason it does in
  the compiler's own flags: it keeps a thread-local read a single segment
  load. This is not a `[features]` gate — threadedness is a property of
  the program being compiled, discovered from its use of `Thread`, not
  something a consumer selects in its manifest.

- **Features**: a `[[build]]` entry gated with `features = ["cuda"]` runs
  when the feature is in the package's own `[features] default` set or
  enabled by the consuming application's manifest: `dep = { path = "..",
  features = ["cuda"] }`, written by `spin add <name> --features cuda`.
  Cargo-style, the manifest is the source of truth and the lock stays
  resolution-only (Cargo.lock records no features either). Root-level
  enablement only; transitive feature unification is out of scope. The
  recommended packaging convention is cargo's `-sys` shape: a leaf package
  carrying the vendored tree, the `[[build]]` entries, and the raw
  `ffi_*` declarations.

### R11 — the flags handoff (implemented; #4105)

`spin flags` prints the compiler flags this project implies — the `-I` roots
for every resolved dependency and the project itself, `--rbs` when it carries
sidecars, `--link` per cached native object, and `--strict-require` — with no
entry file and no `-o`. It is one producer with `spin build`, so what a caller
compiles with is what spin would have compiled with rather than an
approximation of it. Reading the native objects compiles any that are cold,
which is what makes the printed `--link` paths real; that progress goes to
stderr, since stdout is the flag string.

**Why it exists.** R2 keeps *an application is a package with executables* —
one manifest, no second project kind — and that is worth keeping: it is what
lets role be carried by extension instead of by manifest lists. But it means
`spin build` owns the directory it sits in, and some applications live in a
repository whose layout is not spin's to arrange: Ruby and C side by side, one
Makefile driving both, nothing willing to move. Rather than a second project
kind, or a manifest that lists sources after all, spin gets a door: it stays
the supplier of resolved dependencies and compiled native objects, and hands
the build back.

`[package] exclude` (R6) answers the other half, for a tree that does want
`spin build` to own it but holds C that must not be compiled in.

Every printed path is absolute: `find_root` walks up from the working
directory, path dependencies resolve through `File.expand_path`, and cache
objects are named from the cache root. The caller's working directory is its
own tree, not the project's.

`--strict-require` is the compiler flag spelling of `SPINEL_STRICT_REQUIRE`, added
with this: an env assignment cannot ride inside a flag string, and the gate is
part of what `spin build` compiles under.

## 5. Project model

- **Project root** = the nearest ancestor directory containing `spin.toml`
  (upward walk; commands run from any subdirectory).
- Build artifacts are per-project and disposable: `build/bin/<target>`,
  `build/test/<name>` (`spin clean` removes `build/`). `spin` writes
  nowhere else in the project except `spin.toml` (`add`/`remove`),
  `spin.lock`, and `vendor/packages/`.
- Rebuild tracking is the newest-input-mtime of the project and its
  dependency trees (`.rb`/`.rbs`/`.c`/`.h`/`spin.toml` plus the compiler
  binary) against each output — a flat input set; there is deliberately no
  per-file dependency graph, because type specialization spans every
  source. *Aspiration:* content-hash stamps (the compiler-repo scheme)
  instead of mtimes. Package C is cached across projects (R6); `spin` runs no
  *arbitrary* build tasks (no rake surface) — a package's *declared,
  consented* native build steps are the one exception (R10), and projects
  with bespoke steps beyond that call `spin` from their own build system.
- Output: one line per phase; `spin list --json` / `spin tree --json` are
  the machine surface. *Still specification:* `-q`/`-v`, distinct exit
  codes (currently 0/1), test parallelism (`-j`),
  `spin clean --cache`, and `spin remove` refusing while another dependency
  still requires the package. `spin install` (implemented) copies built `bin/`
  executables to `$XDG_BIN_HOME` / `~/.local/bin` (`--prefix` overrides,
  `--uninstall` removes); installing a tool *from the index* is
  deliberately a separate, deferred verb so the rubygems reading of
  `install <name>` never collides with `bin/<name>`.

## 6. spin.lock

TOML, one table per resolved package, written by `spin add`/`remove`/`lock`,
consumed by every build; something you *diff*, never edit:

```toml
[lock.ansi]
version = "0.1.0"        # from the package's own spin.toml at the pinned ref
git = "https://…"        # git and index sources: repo URL
ref = "<commit SHA>"     # always a full SHA, never a branch name

[lock.local]
version = "0.0.0"
path = "../spinel-local" # path deps are recorded but never pinned
```

Resolution against a lock is **verification, not selection**: the lock pins
git/index sources to their SHAs; constraints are re-checked against it, and
only a constraint the pin no longer satisfies triggers reselection (with a
warning). Content integrity rides on the git SHA; tree hashing for
non-git transports would arrive with any such transport.

## 7. Non-goals

- **Runtime loading** of any kind (no dlopen, no late require).
- **Binary package distribution** (no ABI exists; C1).
- **Side-by-side versions** of one package in one application (R4).
- **Install-time code execution** (R2); packages compute nothing at fetch.
- **A hosted registry service** (the git index instead).
- Replacing FFI: it remains the boundary to *external* native libraries.

## 8. Implementation notes

`tools/spin.rb` (+ `tools/spin/toml.rb`), compiled to `bin/spin`;
`tools/spin_e2e.sh` is the hermetic end-to-end check (`make spin-check`,
part of `make check`): scaffold, path/git/index deps, MVS, lock schema,
add/remove/search, tests in both oracle modes, carried C with cache reuse
and staleness, strict require, vendor and offline with and without a
lock.

Being written in the subset, spin also serves as a trap log; the ones its
code works around deliberately (see the comments in place): nil-carrying
`String` returns flow through `""` instead (no first-class `string?`),
arrays-of-tuples and `[]` accumulator arguments go poly-array and poison
string parameters downstream (tab/newline-packed record strings instead),
`\0` cannot separate C-string keys (`\x01` instead), and a method named
`json_str` collides with the runtime's `sp_json_str` symbol.

## 9. Open points

1. **Stdlib carve-out** (R1): which require-only features move from the
   compiler tree into pre-installed packages first (`erb`/`optparse`/`set` are
   the easy three; `json`/`stringio` are C-backed and exercise R6), and the
   `packages/` directory itself.
2. ~~Index seeding / name-registry ownership~~ — decided on #1753:
   publish-PR gate, compat.jsonl as the roadmap sidecar (never in the
   index), mirror conditions + replacement rules under R5's name policy.
   First three names accepted (redis, pg, spinel_kit).
3. **Toolchain versioning**: the `spinel` manifest constraint, R8 probe
   warnings, and spin↔spinel skew handling all wait on the compiler
   carrying a version.
4. R4 enforcement below resolution granularity (per-root provenance on top
   of `-I`).
5. Native-cache eviction (currently: never).
6. `spin lock --update`, `--frozen`, `--dev`/`[dev-dependencies]`,
   index-install (a `spin get`-style verb), `-q`/`-v`/`-j`,
   `spin clean --cache`.
7. Transitive feature unification for R10 (a dependency's dependency
   enabling a feature); consumer enablement is implemented for the root
   application's direct dependencies.
