# src

The C implementation of the compiler: parser bridge, analyzer, and code
generator. This is the compiler `master` ships; the earlier self-hosting
Ruby implementation is preserved on the `self-host` branch.

See [internals/analyze-ir.md](../docs/internals/analyze-ir.md) for the
analyze/codegen contract and [internals/AST.md](../docs/internals/AST.md)
for the node table the parser fills.
