# Bundled tests:
#   - method_name_collision_multi_class
#   - method_named_log_no_math_collision
#   - method_param_unify_to_poly
#   - method_redefinition_warning
#   - multi_arg_block_call

# === method_name_collision_multi_class ===
# Issue #407 case 2/3. Multiple unrelated classes define the
# same method name; cross-class poly-recv widening picks the
# correct param types via arity match.
#
# Pre-fix the scan_new_calls' forward-ref widening at line
# 9910 bailed when more than one user class defined the same
# `mname` (matched_ci_fwd = -2 = ambiguous), leaving every
# candidate's params at the int default. Heterogeneous-array
# iteration (`[T_method_name_collision_multi_class_IndexHandler.new, T_method_name_collision_multi_class_UsersHandler.new].each |h|;
# h.handle(req, res); end`) then C-compiled with
# `T_method_name_collision_multi_class_IndexHandler#handle(int, int)` against a `"/"` arg ->
# Wint-conversion error.
#
# Fix: when the recv is statically `int`/unresolved
# (var-type-table-not-yet-populated case matz called out),
# walk every user class with the method and widen the ones
# whose ptypes count matches the call's arg count. The arity
# filter excludes attr_accessor entries (0-param getters)
# that happen to share the name with a multi-arg def.
#
# Coverage:
#   - Two unrelated classes (Index/T_method_name_collision_multi_class_UsersHandler) define
#     `handle(req, res)` -- both get widened to (string, string)
#     from the heterogeneous-array iteration's "/" + "" call site.
#   - A third class (T_method_name_collision_multi_class_SQLite) has `attr_accessor :handle` (a
#     0-param getter). Its ptypes count (0) doesn't match the
#     call's arg count (2), so the arity filter excludes it
#     from the widening.
#   - The T_method_name_collision_multi_class_SQLite attr_accessor path is still reachable via
#     `db.handle` (0-arg call) and returns the ivar value
#     unchanged.

class T_method_name_collision_multi_class_IndexHandler
  def handle(req, res); "i-" + req + ":" + res; end
end
class T_method_name_collision_multi_class_UsersHandler
  def handle(req, res); "u-" + req + ":" + res; end
end
class T_method_name_collision_multi_class_SQLite
  attr_accessor :handle
  def initialize(name); @handle = name; end
end

handlers = [T_method_name_collision_multi_class_IndexHandler.new, T_method_name_collision_multi_class_UsersHandler.new]
i = 0
while i < handlers.length
  h = handlers[i]
  puts h.handle("/", "ok")
  i += 1
end

db = T_method_name_collision_multi_class_SQLite.new("conn-1")
puts db.handle

# === method_named_log_no_math_collision ===
# Method names that collide with Math module functions (log, sin,
# cos, sqrt, exp, atan2, hypot, ...) should not be misinferred as
# float-returning. Previously, infer_math_and_misc_type blindly
# matched on the method name and returned float regardless of the
# receiver — so a `def log; @log; end` accessor on a non-Math
# class typed callers' locals as float and the downstream
# `obj.log[i]` index emit dispatched as float (bit access). Fix:
# gate the Math.<fn> branch on `recv` being either the literal
# Math module ConstantReadNode or absent.

class T_method_named_log_no_math_collision_Notebook
  attr_accessor :log
  def initialize
    @log = []
  end
  def add(line)
    @log.push(line)
  end
end

n = T_method_named_log_no_math_collision_Notebook.new
n.add("first")
n.add("second")
entries = n.log
puts entries[0]
puts entries[1]
puts entries.length.to_s

# Also verify Math.log still works
puts Math.log(1.0).to_i.to_s

# === method_param_unify_to_poly ===
# Disagreeing call-site types for the same parameter need to widen
# to `poly`. Pre-fix, `scan_new_calls` (obj-recv) and
# `scan_cls_method_calls` (self-call inside the same class) both
# only widened FROM "int": once the first non-int call site set the
# param type, subsequent disagreeing calls were silently accepted
# and the C compiler rejected the eventual mismatched call.
#
# Once the param widens to `poly`, the int / pointer / etc. arguments
# at the call sites need to be boxed via `sp_box_*`. That boxing
# branch was also missing from `compile_typed_call_args`, so even
# after unify produced "poly", the call sites still passed raw
# sp_int / pointers to a sp_RbVal-typed parameter.

class T_method_param_unify_to_poly_CPU
  def feed(x, val)
    val
  end
  # Self-call (no receiver). Lands in scan_cls_method_calls.
  def boot
    feed("hello", 1)
    feed(20, 2)
    feed("world", 3)
  end
end

class T_method_param_unify_to_poly_User
  def initialize(cpu)
    @cpu = cpu
  end
  # Obj-recv call. Lands in scan_new_calls' obj branch.
  def reset
    @cpu.feed(100, 10)
    @cpu.feed("via_user", 20)
    @cpu.feed(500, 30)
  end
end

cpu = T_method_param_unify_to_poly_CPU.new
puts cpu.boot
puts T_method_param_unify_to_poly_User.new(cpu).reset

# === method_redefinition_warning ===
# Issue #667: a method defined again by a later reopening of its class is
# the earlier definition for the program body's calls made before the
# reopening, and the later one after it ("original" then "redefined"), as in
# CRuby (version_redefined_reopen_defs).

class T_method_redefinition_warning_Foo
  def test
    "original"
  end
end

f = T_method_redefinition_warning_Foo.new
puts f.test

class T_method_redefinition_warning_Foo
  def test
    "redefined"
  end
end

puts f.test

# === multi_arg_block_call ===
# Multi-argument `block.call(a, b, ...)` on the proc-object path.
#
# Pre-fix, `compile_proc_literal` hardcoded the lambda's signature
# as `static sp_int <fn>(void *_cap, sp_int lv_<bp>)` — a single
# `sp_int` slot — and the call site always lowered to
# `sp_proc_call(lv_<rname>, <arg0>)`, so any second/third positional
# arg was silently dropped.
#
# Fix collects every block param at proc-literal time and emits
# `(void *_cap, sp_int lv_<bp1>, sp_int lv_<bp2>, ...)`, then
# dispatches the call site to `sp_proc_call_N` (added to the
# runtime: cast the stored function pointer to the matching N-arg
# signature and invoke).
#
# Out of scope: arity-mismatched calls (`proc { |a| } .call(1, 2)`)
# stay UB on the C side. Spinel's static dispatch enforces match in
# the test cases below.

# 1. Basic: forwarded `&block` invoked with 2 args.
class T_multi_arg_block_call_App
  def run(&block)
    block.call(10, 20)
  end
end

T_multi_arg_block_call_App.new.run { |a, b| puts a + b }

# 2. 3-arg block.call.
class T_multi_arg_block_call_Wider
  def go(&block)
    block.call(1, 2, 3)
  end
end

T_multi_arg_block_call_Wider.new.go { |x, y, z| puts x + y + z }

# 3. Same proc invoked twice with different concrete args.
class T_multi_arg_block_call_Twice
  def both(&block)
    block.call(100, 1)
    block.call(200, 2)
  end
end

T_multi_arg_block_call_Twice.new.both { |a, b| puts a * b }

# 4. 0-param block called with one arg. Extra arg is silently dropped
# (matches CRuby semantics). Exercises the `_unused` fallback path
# that the multi-param refactor must leave intact.
class T_multi_arg_block_call_Drop
  def go(&block)
    block.call(99)
  end
end

T_multi_arg_block_call_Drop.new.go { puts "called" }

