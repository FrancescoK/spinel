# Operand-order probe (matz/spinel#11506)

A generated probe of evaluation order. Each case is a method that resets some shared state, evaluates one call shape whose operand slots are filled from a menu, and prints the answer, the order the traced operands ran in, and the state of the variable the operands share. CRuby 4.0 (`ruby --enable-frozen-string-literal`) is the oracle.

- **Shapes (62):** user calls, String, Integer, Array and Hash builtins, operators, index writes, op-assign, multiple assignment, `&.`, block-pass, keywords, splats, interpolation and literals.
- **Kinds:**
  - `order`: every slot traces.
  - `raise`: one slot raises after tracing.
  - `effect`: one slot reads a variable that another slot changes or reassigns. The variable is reached through a local, a proc, an ivar, a method or a global.
  - `two`: one slot mutates the variable and another reassigns it.
- **Hand-written cases:** six.

## Run

```sh
./run_all.sh master=/path/to/spinel/bin/spinel
./run_all.sh before=/path/a/bin/spinel after=/path/b/bin/spinel   # compare builds
```

The probe uses seed 1 and 40 cases a program, which gives 2,508 cases in 63 programs. `JOBS` sets the parallel jobs per build (the default is 2). The output goes to `../gen/`:
- `LABEL.results.tsv`: each case's status (ok, WRONG, CERR, CRASH, MISSING), with the expected and observed lines;
- `families.tsv`: the non-ok cases per family and build;
- the group table, which is printed at the end.

A program that Spinel cannot compile, or that crashes, is split down to the case.

## Baseline

| master | non-ok cases | groups |
|---|---|---|
| `2289bfbde7` (the issue) | 132 order cases | 11 |
| `fdfe105f3a` | 44 order cases, and 1 that is not about order | 6 |

At `fdfe105f3a`:

| group | cases |
|---|---|
| a block-pass expression runs before the arguments | 16 |
| a String mutator's receiver is read after an argument rebound it | 10 |
| `=~` evaluates its pattern ahead of the receiver | 7 |
| `a[i] op= v` answers the slot read again | 4 |
| an operand the callee ignores is not evaluated (`fetch`'s default, a nil block-pass) | 4 |
| a splat is expanded after a later argument ran | 3 |
| not order: a lambda passed through a method's answer as `&blk` gets a mistyped parameter | 1 |
