# Builtin String-flow oracle

Run `ruby --enable-frozen-string-literal tools/gen_builtin_share_spec.rb --write
-o classification.tsv` with CRuby 4.0. `make share-spec-check` regenerates the
observations and detects drift. `make bop-share-check-test` uses only the
committed C table and a separate `build/spinel-share-check` executable: no
reference Ruby is needed. The observation table is absent from the compiler
binary. Set `SPINEL_SHARE_CHECK_VERBOSE=1` to list conservative excess edges;
the default check prints their count.
`ruby --enable-frozen-string-literal tools/builtin_share_spec_test.rb` exercises
the observer on retained arguments, mutation, blocks, and rejected calls.

The public instance surfaces come from the arity generator, including inherited
methods. Its class targets are extended with the explicit share-row names and
ENV's public methods. Both String and Object markers are tried separately at
each positional argument (up to three), as receiver/element where applicable,
and as the block's result. Empty and populated containers and IOs are separate probes. String receivers
include empty, uppercase, normalised, repeated, multibyte and binary contents.
String-ended Ranges are recorded separately from numeric Ranges.
Array and Hash argument shapes also contain markers, so typed container
arguments are exercised. Inaccessible Enumerator reads disqualify a name from
the keeps-nothing table. Generated names with hand contracts are omitted, and
generated contracts never establish boxed receiver behaviour. Target-dependent forwarding methods remain unprobed.
Each method runs in a child with a three-second deadline and private files;
process-control, destructive and blocking operations are explicitly skipped.
The child has a fixed ENV. As in the arity probe, `pread` and
`set_encoding_by_bom` are excluded because mistyped native calls can terminate
the child before it produces observations. The arity generator can be required without running
its probes; its command-line behavior is unchanged.

The JSON records successes, errors, successful argument-count/block/marker
shapes, and a witness for each observed edge. The TSV includes skipped and
unsuccessful methods. A failed call is never evidence that a method keeps
nothing. The C table contains only successful observations. `return` includes
identity reachable through the returned container, bound Method, or Enumerator;
`store` means reachable from the receiver after mutation and a fresh read.
Array/Hash/Struct/Set contents, instance variables and selected native readers
are traversed to depth four. `yield` records the objects handed to the block.
Mutation snapshots cover bytes, encoding, frozen state and visible slots.
Frozen String answers are excluded from mutable return flow.

The checker uses the compiled share and iterator lookups. LESS is a missing
return/store/yield edge or argument mutation and fails the check. Receiver
mutation is recorded separately: it is not forbidden by BSH_PURE, and the
compiler has separate String-mutator facts. MORE is a potential opportunity,
not proof of an unnecessary edge. Masks are receiver=1, element=2, arg0=4,
arg1=8, arg2=16, block result=32. Argument counts and block forms stay separate.
Unknown contracts are counted separately. The generated exact keeps-nothing
names are backed by all successful shapes on their recorded receiver surfaces.

This is an executable regression oracle, not a proof for arbitrary arguments,
user overrides, conversions, keyword combinations, or hidden native storage.
The finite shapes can find a missing edge; absence of an edge cannot prove
universal purity. Review a proposed optimisation against the witnesses and
expand the shapes before weakening a conservative row. Methods that cannot be
observed remain unknown. The JSON is the coverage record, not a suppression
list: compiler rows do not decide which observed edges the generator emits.
