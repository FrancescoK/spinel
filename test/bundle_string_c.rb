# Bundled tests:
#   - str_index_range_eq
#   - str_setbyte_dup_mutates
#   - string_endless_range
#   - string_index_from
#   - string_index_nullable
#   - string_index_oob_returns_nil
#   - string_to_i_underscore

# === str_index_range_eq ===
def t_str_index_range_eq
  # `s[i..i] == "/"` used to skip compile_string_method_expr's `[]`
  # RangeNode arm and hit the `s[i] == "/"` single-char fast path
  # instead (compile_eq_char_index), which cast the RangeNode to
  # sp_int and emitted `lv_s[(sp_int)sp_range_new(i, i)] == '/'` —
  # C compile failure ("aggregate value used where an integer was
  # expected"). Issue #644.
  #
  # Fix: the single-char fast path bails out when the `[]` arg is a
  # Range or a 2-arg `s[start, len]` form, so the call falls through
  # to the proper sp_str_sub_range dispatch + string compare.
  
  s = "abc/def"
  i = 3
  if s[i..i] == "/"
    puts "match"
  end
  
  # Range literal as the [] arg (no LV indirection).
  puts s[1..2]            # "bc"
  puts s[3..3] == "/"     # true
  
  # Exclusive range.
  puts s[3...4] == "/"    # true
  
  # `s[start, len]` 2-arg form must also fall through cleanly.
  puts s[3, 1] == "/"     # true
end
t_str_index_range_eq

# === str_setbyte_dup_mutates ===
def t_str_setbyte_dup_mutates
  # `String#setbyte` on a heap-allocated string mutates in place.
  # Spinel adopts `# frozen_string_literal: true` semantics
  # globally: string literals are frozen (rodata-resident), so a
  # setbyte on a literal raises FrozenError; setbyte on a heap
  # buffer (from .dup, +, *, gsub, etc.) mutates as usual.
  #
  # This test pins the heap-mutate path. Literal -> FrozenError is
  # covered by test/str_setbyte_frozen_literal.
  
  # Dup'd string: setbyte mutates.
  s = "ab".dup
  s.setbyte(0, 67)  # 'C'
  s.setbyte(1, 68)  # 'D'
  puts s   # CD
  
  # String#+ produces a fresh heap buffer too.
  s2 = "x" + "y"
  s2.setbyte(0, 90)  # 'Z'
  puts s2  # Zy
end
t_str_setbyte_dup_mutates

# === string_endless_range ===
def t_string_endless_range
  # #543. `s[1..]` (Ruby 2.6+ endless range) returned an empty
  # string under spinel-AOT instead of the substring from index 1
  # to end. CRuby returns "id" for ":id"[1..]; spinel returned "".
  # Trigger: the codegen lowered `s[1..]`'s RangeNode `right` (an
  # AST -1 sentinel meaning "no value") to literal `0`, then
  # `sp_str_sub_range_r(s, 1, 0, 0)` produced a zero-length slice.
  #
  # Sam Ruby caught this when Roundhouse's router stripped the
  # leading `:` from `:id` pattern segments via `pp[1..]` and the
  # capture key became "" -- every `/articles/N` 404'd because
  # params["id"] was always the default fallback.
  #
  # Fix: in the bracket-call's RangeNode branch, treat the AST -1
  # sentinel for the endpoints as the corresponding end:
  #   - missing left  -> "0"  (s[..k] == s[0..k])
  #   - missing right -> "-1" (s[k..] == s[k..-1])
  # The exclusive flag is ignored on the missing endpoint (CRuby
  # semantics: `s[1..]` == `s[1...]` == `s[1..-1]`).
  
  s = "hello"
  
  # Endless from inclusive lower bound.
  puts s[1..]      # ello
  puts s[1...]     # ello  (CRuby treats endless ... same as ..)
  puts s[-2..]     # lo
  
  # Beginless to inclusive upper bound.
  puts s[..2]      # hel
  puts s[...2]     # he   (exclusive upper)
  
  # The Sam Ruby repro shape: strip the leading char.
  pp = ":id"
  puts pp[1..]     # id
end
t_string_endless_range

# === string_index_from ===
def t_string_index_from
  # Regression: `String#index(sub, start)` 2-arg form.
  # Pre-fix the codegen ignored `start` and re-emitted the 1-arg
  # call, so a "find next dot after position N" walk all returned
  # the first match.
  #
  # Updated for #532: `String#index` now returns nil (not -1) for
  # not-found, matching CRuby. `puts nil.to_s` prints an empty
  # line; the walk-all-dots loop checks `pos.nil?` instead of
  # `pos < 0`.
  
  s = "a.b.c.d"
  
  # 1-arg form -- baseline.
  puts s.index(".").to_s          # 1
  
  # 2-arg form -- the fix.
  puts s.index(".", 0).to_s       # 1   (no skip, finds the same first dot)
  puts s.index(".", 1).to_s       # 1   (start at the dot itself, finds it)
  puts s.index(".", 2).to_s       # 3   (skip past the first dot, find the second)
  puts s.index(".", 4).to_s       # 5
  puts s.index(".", 6).to_s       # "" (nil.to_s; CRuby would print blank)
  
  # Negative start counts from end.
  puts s.index(".", -1).to_s      # "" (not found, nil.to_s)
  puts s.index(".", -2).to_s      # 5    (last dot)
  puts s.index(".", -100).to_s    # "" (before the start: nil, as CRuby)
  
  # Out-of-range positive start.
  puts s.index(".", 100).to_s     # "" (not found, nil.to_s)
  
  # Multibyte: codepoint indexing, not byte indexing.
  m = "α.β.γ"
  puts m.index(".").to_s          # 1   (one cp before the first dot)
  puts m.index(".", 2).to_s       # 3   (after the first dot)
  
  # Walk-all-dots loop -- the JWT use case that surfaced this bug.
  # Idiomatic post-#532: `break if pos.nil?` instead of `pos < 0`.
  t = "header.payload.sig"
  i = 0
  positions = ""
  while true
    pos = t.index(".", i)
    if pos.nil?
      break
    end
    positions = positions + pos.to_s + ","
    i = pos.to_i + 1
  end
  puts positions                  # 6,14,
end
t_string_index_from

# === string_index_nullable ===
def t_string_index_nullable
  # #532. `String#index` / `String#rindex` previously returned
  # sp_int with -1 as the not-found sentinel. The CRuby idiom
  #
  #   pos = body.index('"content"', i)
  #   break if pos.nil?
  #
  # silently broke because `pos.nil?` on a plain-int local is
  # always false (per #521's strict `int == nil`), so the loop
  # never exits and i wanders past the buffer.
  #
  # Fix: widen `String#index` / `String#rindex` to return sp_RbVal
  # (boxed nil for the -1 sentinel, boxed int for found). The
  # CRuby semantics now work end-to-end:
  # - `pos.nil?` / `pos == nil` / `pos != nil` via tag check
  # - `pos.inspect` via sp_poly_inspect (prints "nil" or the int)
  # - `while pos = s.index(...)` truthiness (boxed nil is falsy)
  #
  # Cost: downstream call sites that consume `pos` as a raw int
  # need to unbox. compile_expr_as_int / compile_arg0_as_int in
  # the codegen handle the int-expecting C helper signatures
  # (sp_str_sub_range etc.).
  
  s = "hello world"
  
  # Found and not-found inspect (formerly "6" / "-1"; now "6" / "nil").
  puts s.index("world").inspect    # 6
  puts s.index("xyz").inspect      # nil
  puts s.index("hello").inspect    # 0   (real index 0, not nil)
  
  # CRuby's nil-lens idiom now works without rewrites.
  pos = s.index("xyz")
  puts pos.nil?                    # true
  puts (pos == nil)                # true
  puts (pos != nil)                # false
  
  pos = s.index("hello")
  puts pos.nil?                    # false (real index 0 is NOT nil)
  puts (pos != nil)                # true
  
  # rindex inherits the same shape.
  puts "abcdabcd".rindex("c").inspect    # 6
  puts "abcdabcd".rindex("z").inspect    # nil
  
  # Walk-all idiom from the issue's GPT-2 BPE example.
  body = "header.payload.sig"
  i = 0
  positions = ""
  while true
    pos = body.index(".", i)
    break if pos.nil?
    positions = positions + pos.to_s + ","
    i = pos.to_i + 1
  end
  puts positions                   # 6,14,
end
t_string_index_nullable

# === string_index_oob_returns_nil ===
def t_string_index_oob_returns_nil
  # `"hello"[20]` (single-int index past the end) returns nil in CRuby,
  # not "". Pre-fix spinel's sp_str_sub_range fell through to its
  # OOB branch and returned the empty string, so a `.nil?` check
  # (or any `== nil` comparison) saw a non-NULL pointer and surfaced
  # false. Issue #619 puzzle 3.
  puts "hello"[20].nil?     # true
  puts "hello"[5].nil?      # true (at end of string, single-int index)
  puts "hello"[0].nil?      # false (in bounds)
  puts "hello"[4].nil?      # false (last char)
  puts "hello"[0]           # "h"
  puts "hello"[4]           # "o"
  puts "hello"[-1]          # "o" (negative index normalizes)
  puts "hello"[-99].nil?    # true (past start)
end
t_string_index_oob_returns_nil

# === string_to_i_underscore ===
def t_string_to_i_underscore
  # CRuby's `String#to_i` accepts `_` between consecutive digits and
  # stops at the first non-digit. spinel previously emitted
  # `(sp_int)atoll(s)` which stops at the first `_`, returning 1
  # for "1_2_3asdf" instead of 123. Now routes through
  # sp_str_to_i_cruby. Issue #619 puzzle 1.
  
  p("1_2_3asdf".to_i)
  p("-5_0".to_i)
  p("hello".to_i)
  p("  42  trailing".to_i)
  p("".to_i)
  p("0xFF".to_i)   # CRuby: 0 (only base-10 digits)
end
t_string_to_i_underscore

