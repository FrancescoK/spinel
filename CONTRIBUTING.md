# Contributing to Spinel

## Before you open a pull request

**Run `make gate` on your branch, merged with the current `master`, and
paste its summary into the pull request.** The gate builds the compiler and
runs every leg we merge on: the test corpus, the benchmarks, optcarrot, the
ruby/spec retention gate, scale-test, spin-check and the other property
tests. A pull request is merged only after the same gate passes here.

```sh
git fetch origin && git merge origin/master   # or rebase
make gate 2>&1 | tee gate.log
grep -E 'Tests:|scale-test|gate:' gate.log
```

**If `make gate` fails on our side, the pull request goes back to you**
with a comment naming the failing leg. Please fix it and push again; we do
not fix a failing gate for you.

**If your branch no longer merges cleanly with `master`, it goes back to
you too.** We do not resolve merge conflicts on a contributor's behalf:
please rebase onto the current `master`, run `make gate` again and push.
Many pull requests touch the same functions, so keep a branch small and
rebase it early rather than late.

## The gate in the commit

Run `make hooks` once: it points git at the hooks in `tools/hooks`. When
`make gate` passes, it records the tree it tested and the `master` it was
merged with. `git commit --amend --no-edit` then adds a trailer such as

```
Gate: green tree c5355fd0df33 master c55f919a6452 (linux-aarch64 gcc-14.2.0) tests 5642/0
```

The trailer goes only on a commit that, merged with that `master`, gives
exactly the tested tree; a commit that changed after the gate loses it.
A rebase or any other rewrite keeps the trailer's text but not its truth.
`ruby tools/gate.rb verify <commit>` checks it the same way and says OK,
MISMATCH or NO GATE TRAILER. The pre-commit hook (`ruby tools/gate.rb
check`) refuses a commit that grows `emit_call_body` or any function over
1,000 lines, adds a test whose `.expected` differs from CRuby run with
`--enable-frozen-string-literal` (unless the test is marked
`# spinel: not-cruby`, below), or writes to a fixed `/tmp` path. Where the
gate can't pass natively, `ruby tools/gate.rb linux` runs it in a Linux
container on this branch merged with `master`, and records the same stamp.

`make gate`'s stamp and the `.expected` comparison use `GATE_RUBY`, else
`ruby` from `PATH` when it is Ruby 4.0 or later (`tools/gate-ruby` picks
it); the hooks run under `GATE_RUBY` or `ruby`. Without such a Ruby,
`make gate` skips the stamp and passes or fails exactly as it would
otherwise, and the `.expected` comparison is skipped with a warning. `make gate-tool-test`
tests `tools/gate.rb` itself.

## What the review checks

- **Same answer as CRuby.** Compare a new test's output with CRuby 4.0
  run with `--enable-frozen-string-literal`: Spinel's string literals are
  always frozen. A path Spinel cannot handle is refused at compile time with
  a message; it must never give a different answer silently.
- **No cost where the change does not apply.** If optcarrot's generated C
  changes, show callgrind numbers; its checksum stays 59662. A rise of more
  than 0.05 in any scale-test ratio is a finding.
- **Tests that run everywhere.**
  - A test whose values pass 2^31 (including through `to_r`, `**` or a
    Bignum) starts with `# spinel: int64`; the 32-bit lane runs every other
    test.
  - A test whose `.expected` is Spinel's own answer and legitimately differs
    from CRuby's (a refusal message, a Spinel-only API) carries
    `# spinel: not-cruby` and a reason in its first lines; the pre-commit
    hook then does not compare it with CRuby.
  - Use `Dir.tmpdir` for temporary files, not a fixed `/tmp` path, and no
    OS-specific paths.
  - Give every new test its `.expected` file.
- **Function size.**
  - A function over 1,000 lines does not grow: add a new arm through a
    helper, or in the file for its receiver type.
  - `emit_call_body` only shrinks (#7033).
- **C style.** Helpers are functions, not Ruby-style macros. Generated C
  puts `else` on its own line, not `} else {`. GNU extensions go through
  `sp_compat.h`. `lib/spinel_rt.h` changes are additive only.
- **Mutable Strings (#6179, #6765).** While the share-by-default prototype
  is in progress, a route that silently copies a String a callee appends to
  should be refused at compile time. Please do not add new per-route
  sharing rules.

## Stacked pull requests

If one pull request depends on another, say so in its description, and
keep the shared commits identical (same SHAs) in both, so merging one
brings the other in cleanly.
