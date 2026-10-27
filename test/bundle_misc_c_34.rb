# Bundled tests:
#   - time_utc
#   - times_map_nested_array
#   - toplevel_ivar_array

require "time"  # Time#iso8601 is require-only stdlib (matches CRuby)

# === time_utc ===
def t_time_utc
  # Issue #418. `Time#utc` was unresolved on a Time receiver --
  # emitted a `cannot resolve call to 'utc' on time (emitting 0)`
  # warning and the result fell back to int. Sibling shape to #414
  # (iso8601 / strftime); ActiveRecord's `fill_timestamps` does
  # `Time.now.utc.iso8601` to produce UTC-suffixed timestamp
  # strings, and with iso8601 resolved post-#414 but utc still
  # unresolved, the chain broke one step earlier.
  #
  # Fix:
  #   - Runtime: sp_Time gains an `is_utc` flag (C99 compound
  #     literals zero-init the new field, so existing
  #     `(sp_Time){sec, nsec}` sites stay valid). sp_time_utc(t)
  #     returns the same instant with is_utc set; sp_time_iso8601
  #     and sp_time_strftime check the flag and dispatch through
  #     gmtime when it's set.
  #   - Codegen: compile_object_method_expr's recv_type=="time" arm
  #     dispatches `utc` to sp_time_utc.
  #   - Inference: infer_method_name_type returns "time" when mname
  #     is "utc" and recv resolves to time.
  #
  # Coverage:
  #   - Time.now.utc.iso8601 round-trip (the canonical chain) -- the
  #     output ends in "Z" rather than "+HH:MM".
  #   - Time.now.utc.strftime to verify the flag also reaches the
  #     strftime path.
  #   - utc-then-non-utc (no double-flip): subsequent .utc on an
  #     already-utc time keeps the same shape (idempotent).
  
  t = Time.now.utc
  iso = t.iso8601
  
  # UTC iso8601 form: "YYYY-MM-DDTHH:MM:SSZ" -- 20 chars, ends in Z.
  puts iso.length == 20 ? "utc-iso-len-ok" : "utc-iso-len-bad"
  puts iso[19] == "Z" ? "utc-iso-zulu-ok" : "utc-iso-zulu-bad"
  
  # strftime against UTC: %H is the hour-of-day, which differs from
  # local hour by the timezone offset (unless we're already in
  # UTC). We can't assert an exact value (depends on system clock),
  # but we can verify it's a 2-digit number.
  hh = t.strftime("%H")
  puts hh.length == 2 && hh[0] >= "0" && hh[0] <= "2" ? "utc-hh-ok" : "utc-hh-bad"
  
  # Idempotent: utc on an already-utc time keeps the same shape.
  iso2 = t.utc.iso8601
  puts iso2.length == 20 && iso2[19] == "Z" ? "utc-idempotent-ok" : "utc-idempotent-bad"
  
  # Local iso8601 still works (regression check on #414's path).
  puts Time.now.iso8601.length == 25 ? "local-iso-still-ok" : "local-iso-broken"
end
t_time_utc

# === times_map_nested_array ===
def t_times_map_nested_array
  # #553 (cielavenir). `N.times.map { block-returns-array }`
  # now collects into a sp_PtrArray rather than sp_IntArray.
  # Pre-fix codegen always built sp_IntArray for the outer
  # accumulator, then `sp_IntArray_push` was handed an sp_IntArray
  # pointer as its sp_int second argument -- -Wint-conversion
  # warning at compile time, garbage values at runtime.
  #
  # The fix routes any block-returns-array shape (int_array,
  # str_array, float_array, sym_array, poly_array, or any
  # *_ptr_array nesting) through sp_PtrArray; analyze's
  # `<inner>_ptr_array` static type already existed for the
  # normal `recv.map { array }` arm and the inspect helpers
  # (sp_IntArrayPtrArray_inspect etc.) know how to format it.
  
  a = 2.times.map { (0..2).map { |i| i + 1 } }
  p a
  
  b = 3.times.map { [10, 20, 30] }
  p b
end
t_times_map_nested_array

# === toplevel_ivar_array ===
def t_toplevel_ivar_array
  # Top-level instance variables: `@x` at script scope binds to the
  # main object, the same as inside an instance method. Spinel currently
  # emits `self->iv_x = ...` for ivar access but the script's top-level
  # function has no `self` parameter, so the C compiler errors with
  # `use of undeclared identifier 'self'`. The ivar read also falls
  # through type inference and gets defaulted to `int`, producing a
  # bogus "cannot resolve call to 'push' on int" warning before the
  # hard error.
  
  @n = 0
  @n = @n + 1
  @n = @n + 1
  puts @n
  
  @arr = []
  @arr.push(7)
  @arr.push(8)
  puts @arr.length
  @arr.each { |v| puts v }
end
t_toplevel_ivar_array

