# Sharing verification inputs

The `test/share/verify/*.rb` files match CRuby 4.0 with
`--enable-frozen-string-literal` on the recorded baseline. Their `.expected`
files come from that run. `make share-verify-test` compares generated C with
checking on and off, then runs each executable once against its expected
output, without GC stress. These files have no sharing markers and do not
join `share-strings-test`. The directory keeps 811 of the original 814
programs after normalized-shape deduplication, plus the fresh-argument
checker regression and 11 former conflict examples fixed on master.

`conflicts/` contains two executable examples of existing compiler disagreements.
Their `.expected` files also contain CRuby's output, but master answers
differently. They are compile-only inputs to `share-verify-test`, and are
excluded from `share-strings-test`. Once a compiler fix makes one agree with
CRuby, move it to `test/share/verify/<name>.rb` without a sharing marker,
and remove its resolved entries from `../verify-conflicts.txt`.

The ratchet records exact diagnostics, including the node and dispatch arm.
Another conflict in the same program still fails. An entry that no longer
fires prints a removal reminder without failing the target. A `*` entry applies
only to a program-independent iterator-table error; it is not a wildcard for
return paths or boxes. Classified handle routes and checker coverage gaps
are visible with `ruby tools/share_verify.rb -v`.

The return-channel shadow does not cover every String representation
boundary. An unobserved publication is reported separately from an observed
raw-byte return or a missing fresh-tail clear. Writes in an ensure body
also report a coverage gap: proving which saved return survives that body
requires control-flow information the current shadow does not keep.

A frozen literal is turned into a handle only by `sp_String_new_shared`, which
answers the literal's own handle. Checking reports a `repr-check: conflict:
frozen literal ... is built into a new handle` for any other `sp_String_new*`
constructor given a literal's object (`sp_String_new_unfrozen`, the copy of
`+"lit"`, is allowed), and a conflict fails the target.
