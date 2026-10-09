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

The second stage adds `lib/sp_cext.h` and `make cext-runtime`, an explicitly
selected `lib/libspinel_cext_rt.a`. Only this archive compiles the collector
with `SP_CEXT`; the regular runtime contains neither extension hooks nor their
branches. A C caller enters an arena before converting values, then restores
its checkpoint on return or exceptional unwind. Checkpoints include the arena
depth, so jumping through several nested C calls discards all skipped pins.

The open-addressed table is weak. Arenas, registered `VALUE *` addresses and
`TypedData` mark callbacks root handles. A live Ruby object preserves its
canonical handle even after a C call ends, while dead handles are removed
before the collector can recycle object addresses. Floats are keyed by their
bit patterns; large native integers use handles rather than truncating the
Fixnum representation. Raw string identity is supported here; the compiler's
future boundary stage still must promote strings to shared mutable handles.

Data-class lifecycle helpers provide the prefix, mark/finalize functions and
type-parent checks for the compiler to use later. Non-WB-protected data classes
are pinned remembered; the collector calls `dmark` on minor collections even
when a C store had no write barrier. This stage does not yet provide public
class lookup, allocation macros, send dispatch or threaded extension access.

`make cext-gc-test` checks identity, table resizing, nested arena unwind,
registered-address deduplication/unregistration, weak reclamation, strings,
`TypedData` children and finalization. It repeats under generational verification,
the list allocator and allocation stress.
