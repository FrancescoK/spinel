# #548. Four shapes that compiled cleanly but hung at runtime.
# Adam Doppelt's "Puzzles, third edition."
#
# 1. `a.concat(a, a)` -- two bugs in compile_call_stmt's concat
#    arm. (a) Only the first arg was processed, so multi-arg
#    concat dropped the tail silently. (b) The src-array length
#    was queried inside the push loop; when an arg aliased the
#    receiver (`a.concat(a)`) every push grew the source and
#    the loop never terminated. Fix: snapshot every arg's length
#    before any is appended, then iterate every arg (CRuby
#    appends the arguments as they were: [1,2] + [1,2] + [1,2]).
#
# 2. `/\#{re}/` -- regex compiler entered an infinite loop. The
#    sequence `\#` lowered to literal `#`, then `{re}` arrived
#    at compile_atom with `{` as the leading char. `{` was in
#    compile_atom's "not an atom" filter, so the function
#    returned without consuming and compile_seq's outer loop
#    spun. CRuby treats `/{re}/` as matching the literal text
#    `{re}` (`{...}` without a valid quantifier is literal); we
#    mirror that by removing `{` from compile_atom's filter so
#    a leading `{` falls through to the literal-char emit.
#
# 3. `while () ; 123 ; end` -- empty `()` infers as "void" and
#    lowers to literal `0`. compile_cond_expr's catch-all
#    `((expr), TRUE)` flipped the empty-parens condition to
#    always-true and the loop hung. Treat "void" like "nil" in
#    compile_cond_expr -- both lower to FALSE so `while ()`
#    never enters the body, matching CRuby.
#
# 4. `i += 1; raise; rescue; retry unless i == 7` -- setjmp/
#    longjmp local-preservation. `lv_i` modified inside the
#    setjmp scope must be `volatile` to survive longjmp's
#    register-unwind; with `-O3` the compiler register-cached
#    `lv_i` and the rescue handler saw a stale 0, so `i == 7`
#    was never satisfied and retry spun forever. Fix: pre-scan
#    method bodies for setjmp-triggering shapes (begin/rescue,
#    raise, retry) and mark non-pointer locals as `volatile`.
#    Pointer locals stay non-volatile (GC-rooted via
#    SP_GC_ROOT already keeps them stable; tagging them
#    volatile triggers -Wdiscarded-qualifiers cascade at
#    string/array helper call sites).

# Repro 1: self-concat with self twice.
a = [1, 2]
a.concat(a, a)
puts a.length      # 6 -- [1,2] + [1,2] + [1,2]

# Repro 2: regex with literal `\#{re}` characters.
re = /foo|bar/
r2 = /\#{re}/
puts "ok2"

# Repro 3: while () never enters.
while () ; 123 ; end
puts "ok3"

# Repro 4: retry-counter survives longjmp.
def foo
  i = 0
  begin ; i += 1 ; raise "bar" ; rescue ; retry unless i == 7 ; end
  raise "baz" unless i == 7
rescue
  123
end
puts foo  # 123  (foo's body would also raise "baz" if i != 7; here i == 7
          #       so no raise, and the function falls through. The
          #       outer rescue is dead code for this path.)
