# Restricted C extension layer

The first stage of #7210 supplies the immediate value representation and
standalone headers. It does not load CRuby binaries or enable requiring C
extensions yet. Include these headers explicitly with `-Iinclude`; ordinary
Spinel builds continue using the existing runtime.

`make cext-header-test` checks pointer width, signed Fixnum boundaries (with
UBSan), nil/boolean truthiness, Symbol round trips, handle discrimination,
and compile-time diagnostics for unsupported object layout access and eval.

Fixnum conversion macros take values in `RUBY_FIXNUM_MIN..RUBY_FIXNUM_MAX`;
heap integer conversions belong to the runtime layer. `VALUE` uses unsigned
shifts so negative immediate encoding has no signed-shift undefined behaviour.
Symbols are static IDs; the later source scanner must restrict computed method
IDs before enabling extension dispatch.

The encoding and thread headers currently declare no operations. `rb_io_t`
contains only `fd` and `mode`; obtaining it from a Ruby IO belongs to the IO API
stage. Unsupported layout access emits a compiler error on GCC and Clang;
other compilers still refuse at link time rather than providing an ABI.
