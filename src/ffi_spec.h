#ifndef FFI_SPEC_H
#define FFI_SPEC_H

#include "types.h"   /* TyKind */

/* The FFI type-spec vocabulary in one place.
 *
 * An FFI declaration (`ffi_func :abs, [:int], :int`, and the forms layered on
 * top of it) describes each value by a spec token -- "int", "long", "ptr",
 * "str", "double", .... Every place that needs to know something about a spec
 * -- its inferred Ruby type (ffi_spec_to_ty) and its C type at the ABI boundary
 * (ffi_c_type) -- resolves it through this single table, so the two can never
 * disagree. Adding a type is one row here; there is no second table to keep in
 * sync. LP64 target (arm64-darwin / x86_64-linux). */
typedef struct {
  const char *spec;    /* the spec token */
  TyKind      ty;      /* inferred Ruby type of a value of this spec */
  const char *c_type;  /* C type at the ABI boundary */
} FfiSpecInfo;

/* The row for `spec`, or NULL if the token is not part of the vocabulary. */
const FfiSpecInfo *ffi_spec_lookup(const char *spec);

/* Does `spec` hand C a Ruby String's bytes (:str, :binstr, :string)? A
   String argument may be a heap String only the call holds. */
int ffi_spec_is_str(const char *spec);

/* The C type an `ffi_read_<kind>` / `ffi_write_<kind>` suffix names, or NULL
   when the suffix is not a scalar one ("ptr", or a typo). Kept beside the spec
   table for the same reason: the declaration side validates the suffix and the
   emitter picks the load width from one answer, so a suffix cannot be accepted
   under one width and read at another. */
const char *ffi_scalar_ctype(const char *kind);

/* The byte width that suffix loads and stores ("ptr" is a pointer), or 0 for
   a suffix outside the vocabulary. The bounds check against a declared
   `ffi_buffer` needs the width the access really touches, and taking it from
   the same table is what keeps the two in step. */
int ffi_scalar_width(const char *kind);

#endif /* FFI_SPEC_H */
