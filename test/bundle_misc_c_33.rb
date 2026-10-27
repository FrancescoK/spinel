# Bundled tests:
#   - sym_hash_method_dispatch
#   - time_accessors
#   - time_iso8601_strftime

require "time"  # Time#iso8601 is require-only stdlib (matches CRuby)

# === sym_hash_method_dispatch ===
def t_sym_hash_method_dispatch
  # #510. `sym_str_hash` and `sym_poly_hash` got the right type
  # tag at analyze time but the codegen dispatch had no arms for
  # merge / fetch / dup / delete — every call emitted 0 with a
  # "cannot resolve call to '<m>' on sym_<x>_hash" warning.
  #
  # Fix: added codegen arms for the missing operations, with
  # matching runtime helpers (sp_SymStrHash_merge, sp_SymPolyHash_delete)
  # emitted alongside the existing sp_SymStrHash_* set / declared in
  # the runtime header. fetch's default value is boxed via
  # box_expr_to_poly so the ternary's arms agree on sp_RbVal type.
  # Analyze: fetch on sym_poly_hash / str_poly_hash returns poly
  # (so the receiving LV slot widens to sp_RbVal).
  
  # sym_str_hash.merge
  base = { href: "/path" }
  extra = { class: "btn" }
  puts base.merge(extra).length
  
  # sym_str_hash.dup
  h = { a: "1", b: "2" }
  d = h.dup
  puts d.length
  
  # sym_str_hash.delete
  h2 = { a: "1", b: "2", c: "3" }
  h2.delete(:b)
  puts h2.length
  
  # sym_poly_hash.fetch with default
  opts = { method: :delete, form_class: "btn-form", id: 42 }
  m = opts.fetch(:method, :nope)
  puts m
  n = opts.fetch(:missing, :fallback)
  puts n
  
  # sym_poly_hash.dup + delete
  od = opts.dup
  od.delete(:method)
  puts od.length
end
t_sym_hash_method_dispatch

# === time_accessors ===
def t_time_accessors
  # Local Time.new + broken-down accessors + scalar inspect +
  # utc_offset / zone. Accessors are checked against Time.at(0).utc
  # so the expected values are TZ-independent. Time.new is checked by
  # reading the constructed value back in the same local zone, which
  # also round-trips regardless of the host TZ.
  u = Time.at(0).utc
  puts u.year
  puts u.mon
  puts u.mday
  puts u.hour
  puts u.min
  puts u.sec
  puts u.wday
  puts u.yday
  puts u.utc_offset
  puts u.zone
  puts u.isdst
  puts u.dst?
  p u
  puts u
  
  t = Time.new(2026, 5, 16, 9, 30, 15)
  puts t.year
  puts t.mon
  puts t.mday
  puts t.hour
  puts t.min
  puts t.sec
  puts Time.new(2026).mon
  puts Time.new(2026).mday
  puts Time.new(2026).hour
  
  a = Time.at(0).utc
  b = Time.at(1).utc
  puts(a < b)
  puts(b > a)
  puts(a <= Time.at(0).utc)
  puts(a >= Time.at(0).utc)
  puts(a == Time.at(0).utc)
  puts(a != b)
  puts(a <=> b)
  puts(b <=> a)
  puts(a <=> Time.at(0).utc)
  puts(a == Time.at(0))
  puts((Time.at(0) + 60).to_i)
  puts((Time.at(100) - 40).to_i)
  puts((Time.at(0).utc + 1).zone)
  c = Time.at(1000) + 234
  puts c.to_i
  puts((Time.at(10) + 0.5).to_f)
  puts((Time.at(10) - 0.5).to_f)
  puts((Time.at(0) + 1.5).to_i)
  puts((Time.at(0) + 2.25).to_f)
  puts((Time.at(5) - 1.25).to_f)
end
t_time_accessors

# === time_iso8601_strftime ===
def t_time_iso8601_strftime
  # Issue #414. `Time#iso8601` and `Time#strftime` were unresolved on
  # a Time receiver -- spinel emitted a `cannot resolve call to ...
  # on time (emitting 0)` warning and the result fell back to int.
  # Downstream `.length` / string concat then either cascaded more
  # (emitting 0) warnings or surfaced as a C-compile error at any
  # typed-string sink.
  #
  # Fix:
  #   - Runtime: sp_time_iso8601(t) and sp_time_strftime(t, fmt) in
  #     lib/sp_runtime.h, both delegating to libc strftime against
  #     the local-time broken-down value. iso8601 splices a colon
  #     into the %z offset to match CRuby's "+HH:MM" form.
  #   - Inference: infer_method_name_type returns "string" when
  #     mname is "iso8601" / "strftime" AND recv is a Time.
  #   - Codegen: compile_object_method_expr's `recv_type == "time"`
  #     arm dispatches to the new runtime helpers.
  #
  # Coverage: shape rather than exact-string assertions, since the
  # output depends on the system clock + local-time offset. We
  # assert that both calls return a string of the expected length
  # and that the surrounding format characters land in the right
  # positions.
  #
  # The runtime computes the offset via mktime(gmtime(s)) - s rather
  # than strftime's %z, so the format is stable across libcs --
  # previous attempts relied on POSIX %z (±HHMM) but Windows MSVCRT
  # emits the timezone *name* instead, blowing past any reasonable
  # length cap.
  
  t = Time.now
  iso = t.iso8601
  
  # iso8601 produces exactly "YYYY-MM-DDTHH:MM:SS[+-]HH:MM":
  # 19 chars for the date+time prefix + 6 chars for the offset = 25.
  puts iso.length == 25 ? "iso-len-ok" : "iso-len-bad"
  
  # Per-position shape: dashes at 4/7, T at 10, colons at 13/16,
  # sign at 19, colon at 22.
  puts iso[4] == "-" && iso[7] == "-" && iso[10] == "T" &&
       iso[13] == ":" && iso[16] == ":" &&
       (iso[19] == "+" || iso[19] == "-") && iso[22] == ":" ? "iso-shape-ok" : "iso-shape-bad"
  
  # strftime: a fixed-format that survives clock variation.
  ymd = t.strftime("%Y-%m-%d")
  puts ymd.length == 10 ? "ymd-len-ok" : "ymd-len-bad"
  puts ymd[4] == "-" && ymd[7] == "-" ? "ymd-shape-ok" : "ymd-shape-bad"
  
  # strftime year-only: 4 digits.
  yr = t.strftime("%Y")
  puts yr.length == 4 ? "yr-ok" : "yr-bad"
end
t_time_iso8601_strftime

