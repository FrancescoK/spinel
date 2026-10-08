# Bundled tests:
#   - poly_recv_dispatch_includes_subclasses
#   - poly_recv_dispatch_narrow
#   - poly_recv_each
#   - poly_recv_ivar_narrow_drops_unrelated
#   - poly_recv_setter_widens_ivar
# spinel: share
# === poly_recv_dispatch_includes_subclasses ===
# Polymorphic-receiver dispatch must include subclass arms when the
# ivar's observed types narrow to a base class but the runtime value
# may be a subclass instance written via a typed setter. Without this
# the dispatch loop only emits the base-class arm and a subclass
# override is silently skipped — the #616 filter-elision shape (tep's
# `app.@before_filter.before(req, res)` where the override never
# fires because @before_filter is declared `Tep::Filter` but the
# stored runtime value is `TepFilters_before`).

class T_poly_recv_dispatch_includes_subclasses_Pipeline
  attr_accessor :step
  def initialize; @step = T_poly_recv_dispatch_includes_subclasses_Step.new; end
  def set_step(s); @step = s; end
  def run(out)
    @step.process(out)
  end
end

class T_poly_recv_dispatch_includes_subclasses_Step
  def process(out)
    out[:base] = "ran"
  end
end

class T_poly_recv_dispatch_includes_subclasses_UpcaseStep < T_poly_recv_dispatch_includes_subclasses_Step
  def process(out)
    out[:sub] = "UPPER"
  end
end

p = T_poly_recv_dispatch_includes_subclasses_Pipeline.new
p.set_step(T_poly_recv_dispatch_includes_subclasses_UpcaseStep.new)
result = { base: "" , sub: "" }
p.run(result)
puts result[:base]   # "" (base override not invoked)
puts result[:sub]    # "UPPER" (subclass override invoked)

# === poly_recv_dispatch_narrow ===
# #513. When `obj.run(arg)` virtual-dispatched through an
# unpinned receiver slot, the generated cls_id switch
# enumerated EVERY class that defines `run`, not just classes
# that can reach the receiver. Unrelated classes that share
# the method name got pulled into the switch and their
# parameters were widened to sp_RbVal to accept the dispatch
# site's arg.
#
# Fix: when scan_new_calls' poly-recv widening fires for
# `recv.mname(...)` and the recv is an ivar read, compute the
# observed-class set for that ivar via observed_class_ids_for_recv.
# When the recorded observation is just "poly" (because the rhs
# of `@x = w` was a poly-typed param), walk the class's call
# sites for the enclosing method and aggregate the concrete
# obj types observed at the matching arg position. Restrict
# the per-class param-widening loop to that set.
#
# The codegen-side cls_id-switch then naturally drops the
# unrelated arms via the existing arm_incompat check: classes
# whose `run` param stayed at the original concrete type can't
# accept the dispatch site's (different concrete) arg, so the
# arm is suppressed.

class T_poly_recv_dispatch_narrow_WorkerA
  def run(item)
    item + "!"
  end
end

class T_poly_recv_dispatch_narrow_WorkerB
  def run(item)
    item + "?"
  end
end

class T_poly_recv_dispatch_narrow_Holder
  def initialize(w)
    @w = w
  end
  def use(item)
    @w.run(item)
  end
end

class T_poly_recv_dispatch_narrow_Server
  def run(port)
    port + 1
  end
end

# The fix: T_poly_recv_dispatch_narrow_Server#run's `port` stays sp_int (not widened to
# sp_RbVal by the @w.run(item) dispatch), so the int arithmetic
# `port + 1` compiles cleanly and the direct call
# `T_poly_recv_dispatch_narrow_Server.new.run(80)` doesn't have a poly-cast/unbox layer.
puts T_poly_recv_dispatch_narrow_Holder.new(T_poly_recv_dispatch_narrow_WorkerA.new).use("x")
puts T_poly_recv_dispatch_narrow_Holder.new(T_poly_recv_dispatch_narrow_WorkerB.new).use("y")
puts T_poly_recv_dispatch_narrow_Server.new.run(80)

# === poly_recv_each ===
# `<poly>.each` runtime dispatch on cls_id. The compile_each_block
# handler previously bailed when the receiver type was `poly` (no
# matching `if rt == "..."` branch), so a method body that ends in
# `iterable.each do |a| ... end` over a poly slot silently dropped
# the iteration.
#
# Repro: an ivar `@store` widened to poly via two distinct array
# shapes (an int_array and a poly_array) is iterated via `.each`.
# Spinel previously emitted no loop at all — the body never ran.
# The block param `a` is delivered as sp_RbVal (the widest fit
# across the cls_id arms).

class T_poly_recv_each_C
  def store_int_array
    @store = [10, 20, 30]
  end
  def store_poly_array
    @store = [nil] * 3
    @store[0] = "a"
    @store[1] = "b"
    @store[2] = "c"
  end
  def visit
    @store.each do |x|
      puts x.to_s
    end
  end
end

c = T_poly_recv_each_C.new
c.store_int_array
c.visit
puts "---"
c.store_poly_array
c.visit

# === poly_recv_ivar_narrow_drops_unrelated ===
# Poly-recv user-class dispatch on an ivar previously dragged in
# arms for any class that happened to share the method name, even
# when that class was never assigned to the ivar (never even
# instantiated). Issue #575: an unrelated `run` method on
# T_poly_recv_ivar_narrow_drops_unrelated_Unrelated leaked into the @worker dispatch and forced the
# result temp to widen to sp_RbVal, breaking the downstream
# typed-string consumer.
#
# Fix has two parts:
#   (a) compile_poly_method_call's emit loop consults the existing
#       poly_dispatch_narrow_class_set helper (it was already
#       used by the return-type union but missing from the arm
#       emit).
#   (b) A new analyzer pass forward-propagates each `<C>.new(args)`
#       callsite's arg types into the ivar observations for any
#       `@ivar = pname` write in C#initialize, so the narrow set
#       isn't blocked by the param-union "poly" entry that the
#       writer-scan would have recorded.

class T_poly_recv_ivar_narrow_drops_unrelated_Worker
  def run(item)
    item + ""
  end
end

class T_poly_recv_ivar_narrow_drops_unrelated_Other < T_poly_recv_ivar_narrow_drops_unrelated_Worker
  def run(item)
    item + "!"
  end
end

# T_poly_recv_ivar_narrow_drops_unrelated_Unrelated to T_poly_recv_ivar_narrow_drops_unrelated_Worker. Never instantiated, never assigned to a
# T_poly_recv_ivar_narrow_drops_unrelated_Pool@worker slot. Its `run` has zero formal args and returns
# Integer — pre-fix this leaked into the dispatch and dragged the
# result type to sp_RbVal, tripping the downstream File.write.
class T_poly_recv_ivar_narrow_drops_unrelated_Unrelated
  def run
    1
  end
end

class T_poly_recv_ivar_narrow_drops_unrelated_Pool
  attr_accessor :worker
  def initialize(w); @worker = w; end
  def go(item, path)
    File.write(path, @worker.run(item))
    0
  end
end

T_poly_recv_ivar_narrow_drops_unrelated_Pool.new(T_poly_recv_ivar_narrow_drops_unrelated_Worker.new).go("a", "spinel_poly_recv_ivar_narrow_a.txt")
T_poly_recv_ivar_narrow_drops_unrelated_Pool.new(T_poly_recv_ivar_narrow_drops_unrelated_Other.new).go("b", "spinel_poly_recv_ivar_narrow_b.txt")
puts File.read("spinel_poly_recv_ivar_narrow_a.txt")
puts File.read("spinel_poly_recv_ivar_narrow_b.txt")
File.delete("spinel_poly_recv_ivar_narrow_a.txt")
File.delete("spinel_poly_recv_ivar_narrow_b.txt")

# === poly_recv_setter_widens_ivar ===
# #579 (Sam Ruby). `recv.attr = val` where `recv` is statically
# poly (typed sp_RbVal because it came from `case ... when X
# then T_poly_recv_setter_widens_ivar_A.new; when Y then T_poly_recv_setter_widens_ivar_B.new`) lowers to a cls_id-switch
# dispatch in codegen -- each arm does `((sp_C *)_t.v.p)->iv_x = rhs`.
# The analyzer's ivar-type pass only observed setters when recv
# was a single obj_X type; for poly-recv setters every candidate
# class's iv_x stayed at whatever its initialize-time default
# typed it as (e.g. `@data = {}` → sp_StrIntHash *). The per-arm
# assignment then mismatched the wider RHS at the C boundary.
#
# Fix: when scan_writer_calls sees `recv.attr = val` with recv_t
# == "poly", iterate every class that declares the matching
# attr_writer and call update_ivar_type on each. Mirrors the
# codegen dispatch's behavior: every candidate class receives
# the assignment at runtime, so every candidate's ivar type
# must widen against the RHS.

class T_poly_recv_setter_widens_ivar_Base
  attr_accessor :data
  def initialize
    @data = {}
  end
end

class T_poly_recv_setter_widens_ivar_A < T_poly_recv_setter_widens_ivar_Base
end

class T_poly_recv_setter_widens_ivar_B < T_poly_recv_setter_widens_ivar_Base
end

# Force the receiver into the poly shape via a case-expression
# whose branches return different sibling subclasses.
n = 1
receiver = case n
           when 0 then T_poly_recv_setter_widens_ivar_A.new
           when 1 then T_poly_recv_setter_widens_ivar_B.new
           end
merged = { "name" => "foo" }
receiver.data = merged
puts receiver.data["name"]

