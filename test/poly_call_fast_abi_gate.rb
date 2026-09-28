# Regression: the NO-user-`call` poly `.call` fast path and the poly `[]`
# runtime arms must apply the same per-position legacy sp_int ABI gate as the
# shadowed pre-arm.
#
# Five counts that used to be refused here are answered now: the boxed side
# channel carries SP_PROC_ARG_SLOTS arguments rather than a hard-coded 16, so
# a 17-parameter target is callable and a 20-argument call on a 16-parameter
# one reaches the target to be told its own ArgumentError -- both what CRuby
# answers, verified against it. The refusals that remain are about a
# per-position TYPE the target cannot read, which is what this file is for;
# a count the channel can carry is no longer one of them. This file deliberately defines no user class `call`, so
# the fast path in emit_call_body is selected -- poly_call_legacy_abi_gate.rb
# covers the user-`call` pre-arm.
#
# The gate must not be all-or-nothing: a mixed int+pointer target is callable
# when each argument class matches its parameter (the call site knows each
# argument's class, the target stamps a per-position type signature, so a
# String parameter does not accept an IntArray). An
# attr/Struct accessor Method's synthesized __bam_ wrapper carries its bound
# receiver in the leading self slot, so that receiver must not be counted as a
# positional parameter. A StrArray adapter launders its String element through
# the sp_int slot and is stamped with the pointer class at that position. A
# signature/arity mismatch declines (NoMethodError) rather than reading the
# wrong C type. A top-level Method has no self, so the `[]` arms must call it
# self-less. A rest parameter ALWAYS declines on both paths: the callee
# signature's trailing sp_PolyArray* has no slot in the static cast, and the
# prologue roots the garbage register it would receive (see
# poly_call_legacy_abi_gate.rb and issue_3231.rb).
#
# The snapshot is hand-written. Since #4542 a target the stamped ABI cannot
# take rides the per-target thunk its bind site stamped, so most of the
# former declines answer as CRuby does; what still diverges is the thunk's
# boundary check (an argument of another kind than the compiled parameter is
# a TypeError here, where CRuby runs the body with it), a class method that
# takes its class, a bound builtin's wrapper, and the 16-slot cap.

def expect_nome(label)
  yield
  puts "#{label}: no raise"
rescue NoMethodError
  puts "#{label}: NoMethodError"
rescue TypeError => e
  # a value the typed array cannot hold is the TypeError every typed-array
  # store raises (#4481), the adapter route included; the thunk's boundary
  # check (#4542) is another
  puts "#{label}: TypeError: #{e.message}"
rescue ArgumentError => e
  # a count the target's signature cannot bind: the thunk's ArgumentError,
  # in CRuby's words (#4542)
  puts "#{label}: ArgumentError: #{e.message}"
end

# The count guards raise CRuby's ArgumentError (both engines); record the
# class so a silently-dropped or zero-filled argument shows up as ": no raise".
def expect_raise(label)
  yield
  puts "#{label}: no raise"
rescue => e
  puts "#{label}: #{e.class}"
end

class Base
  def mixed(i, s) = i + s.length
  def str_method(s) = s.length
  def iarr_method(a) = a.length
  def opt(a, b = 10) = a + b
  def two_args(a, b) = a + b
  def three_args(a, b, c) = a + b + c
  # A crash regression (see the corresponding case in the legacy gate): the
  # fast path must decline before this allocating body runs.
  def rest_unused(a, *r)
    x = "abc"
    i = 0
    while i < 100_000
      y = [x, x, x]
      i += y.length
    end
    a
  end
  def rest_anon(a, *) = a
  def self.cmethod(a) = self.name.length + a
end

# A descendant makes the class method's C signature lead with its receiving
# class (cmethod_takes_self_cls), which the legacy cast cannot supply.
class Derived < Base; end

# Seed the pointer parameter so the emitted signature is sp_String *; without
# a call site the analyzer leaves `s` untyped (sp_int), which is a different,
# already-declined case.
Base.new.str_method("seed")
Base.new.mixed(0, "seed")
Base.new.iarr_method([1, 2, 3])

# mixed int+pointer: each call argument class matches its parameter
puts [Base.new.method(:mixed)][0].call(2, "b")
# all-pointer target
puts [Base.new.method(:str_method)][0].call("hello")
# arity mismatch declines
expect_nome("arity") { [Base.new.method(:two_args)][0].call(1) }
# a rest parameter always declines (crash regression above)
expect_nome("rest_unused") { [Base.new.method(:rest_unused)][0].call(1, 2, 3) }
expect_nome("rest_anon")   { [Base.new.method(:rest_anon)][0].call(1, 2, 3) }
expect_nome("rest_aref")   { [Base.new.method(:rest_unused)][0][5] }
expect_nome("rest_slice")  { [Base.new.method(:rest_unused)][0][1, 2] }
# a class method whose C signature needs its receiving class declines
expect_nome("cmethod") { [Base.method(:cmethod)][0].call(5) }

class C
  attr_accessor :x
  def initialize = @x = 5
end
c = C.new
puts [c.method(:x)][0].call
puts [c.method(:x=)][0].call(7)
puts c.x

S = Struct.new(:a, :b)
s = S.new(1, 5)
puts [s.method(:a)][0].call
puts [s.method(:b=)][0].call(9)
puts s.b

# A typed-array adapter's Ruby return must be boxed by its recorded kind, not
# mis-tagged as an Integer: push answers the array, StrArray []= the string.
a = ["x"]
puts [a.method(:push)][0].call("y").inspect
puts a.inspect
puts [a.method(:[]=)][0].call(0, "z").inspect
puts a.inspect
ia = [1, 2]
puts [ia.method(:push)][0].call(3).inspect
puts ia.inspect

# A StrArray `[]` wrapper returns a String through the sp_int register; the
# stamped String return kind boxes it (an out-of-range read answers nil).
sg = ["x", "z"]
puts [sg.method(:[])][0].call(0)
puts [sg.method(:[])][0].call(9).inspect

# The `[]` slice/index arms must honour the stamped arity too
expect_nome("slice_arity") { [Base.new.method(:three_args)][0][3, 4] }
expect_nome("index_arity") { [Base.new.method(:two_args)][0][5] }

# The pointer positions must agree by type, not merely by pointer-ness.
expect_nome("ptr_mismatch")  { [Base.new.method(:str_method)][0].call([1, 2, 3]) }
expect_nome("ptr_mismatch2") { [Base.new.method(:iarr_method)][0].call("hello") }

# An UnboundMethod read out of a container is not callable.
um = Base.new.method(:two_args).unbind
umslot = [um]
expect_nome("unbound_call")  { umslot[0].call(1, 2) }
expect_nome("unbound_aref")  { umslot[0][5] }

# An optional parameter is callable at full arity only.
puts [Base.new.method(:opt)][0].call(1, 2)
puts [Base.new.method(:opt)][0][3, 4]
expect_nome("optional_short") { [Base.new.method(:opt)][0].call(1) }

# A typed-array adapter Method reports the CRuby arity of the Array op it
# stands in for (-1), not a nil placeholder (#4395).
pa = ["x"].method(:push)
pslot = [pa]
puts "adapter_arity: #{pslot[0].arity.inspect}"

# A self-less top-level Method must be called without a self argument
def top_add(a, b) = a + b
def top_one(a) = a + 1
puts [method(:top_add)][0][1, 2]
puts [method(:top_one)][0][5]

# `@table[i][j]` dispatch table narrowed to int
class Table
  def initialize
    @ops = [method(:top_one)]
  end
  def run(i, j) = @ops[i][j]
end
puts Table.new.run(0, 5)

# A splatted Method call wider than the 16-slot proc ABI declines rather than
# truncating to the first 16 arguments: the spread helper has no register for
# the surplus, and CRuby itself raises ArgumentError for the identical count.
class Wide
  def m16(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16)
    a1 + a16
  end
end
wide_args = (1..20).to_a
expect_nome("splat_over") { [Wide.new.method(:m16)][0].call(*wide_args) }
# ... and the same through the Method#to_proc wrapper: the generic trampoline
# must see the overlong count, not a clamped 16, or it silently truncates.
expect_nome("toproc_splat_over") { [Wide.new.method(:m16)][0].to_proc.call(*wide_args) }

# A pointer argument to a scalar (int-inferred) parameter declines on both the
# static and the spread path: the generic Method trampoline has only the raw
# sp_int slots and would otherwise read the String pointer as an Integer.
class ScalarArg
  def add1(x) = x + 1
end
puts ScalarArg.new.add1(5)
expect_nome("ptr_arg")   { [ScalarArg.new.method(:add1)][0].call("s") }
ptr_args = ["s"]
expect_nome("ptr_splat") { [ScalarArg.new.method(:add1)][0].call(*ptr_args) }

# A rest parameter reached by a trailing runtime splat declines on the static
# bound-Method path too: the splat's surplus would land in the trailing
# sp_PolyArray* slot as an sp_int and the callee prologue would root it.
rest_runtime_args = [1, 2, 3]
expect_nome("rest_splat_static") { Base.new.method(:rest_unused).call(*rest_runtime_args) }

# A statically-bound fixed-arity Method given a runtime splat must validate
# the run-time count: previously a short splat filled the missing slots and a
# long one dropped the surplus.
expect_raise("static_splat_short") { Base.new.method(:two_args).call(*[1]) }
expect_raise("static_splat_long")  { Base.new.method(:two_args).call(*[1, 2, 3]) }
expect_raise("static_call_over")   { Wide.new.method(:m16).call(*wide_args) }
expect_raise("static_toproc_over") { Wide.new.method(:m16).to_proc.call(*wide_args) }

# A parameter default that reads an earlier parameter is evaluated at the call
# site; the bound-Method path must alias the earlier argument so `a` resolves
# (it used to emit the callee's `lv_a`, a C compile failure).
class RefDefault
  def m(a, b = a + 5) = [a, b]
end
puts RefDefault.new.method(:m).call(1).inspect
ref_arg = [1]
puts RefDefault.new.method(:m).call(*ref_arg).inspect

# A typed-array adapter's synthesized C function has a fixed parameter count:
# supplying fewer leaves its later parameters reading an undefined register
# (a garbage element written into the array) where CRuby raises ArgumentError.
adapt = [1, 2]
expect_raise("adapter_set_short")  { adapt.method(:[]=).call(0) }
expect_raise("adapter_set_splat")  { adapt.method(:[]=).call(*[0]) }
empty_args = []
expect_raise("adapter_set_empty")  { adapt.method(:[]=).call(*empty_args) }
sadapt = ["x"]
expect_raise("sadapter_set_short") { sadapt.method(:[]=).call(0) }

# A rest target whose optionals before the rest are omitted cannot be expanded
# into the fixed cast (the omitted registers and the rest pointer are never
# passed): decline like the poly-slot route instead of calling out of bounds.
class RestOpt
  def m(a, b = 2, *r) = a + b
end
expect_nome("rest_opt_short") { RestOpt.new.method(:m).call(1) }
puts RestOpt.new.method(:m).call(1, 9).inspect

# A typed-array adapter holds one element kind. CRuby's Array is
# heterogeneous, so a value the typed array cannot hold declines with the same
# NoMethodError the poly-slot route raises -- not an index-style TypeError and
# not the pointer read as an Integer. An INDEX still converts (or raises
# CRuby's TypeError), and a zero-argument `[]` call is CRuby's ArgumentError,
# not a padded index 0.
ia6 = [1, 2]
expect_nome("iarr_push_str")   { ia6.method(:push).call("z") }
expect_nome("iarr_push_float") { ia6.method(:push).call(5.5) }
expect_nome("iarr_set_str")    { ia6.method(:[]=).call(0, "z") }
expect_nome("iarr_poly_push")  { [ia6.method(:push)][0].call("z") }
expect_nome("iarr_poly_set")   { [ia6.method(:[]=)][0].call(0, "z") }
# The splat element is tagged by its ABSOLUTE adapter position: a fixed index
# before the splat must not make the value element be treated as the index.
strval = ["z"]
expect_nome("iarr_set_splat_after_idx") { ia6.method(:[]=).call(0, *strval) }
ia10 = [1, 2]
intval = [7]
puts ia10.method(:[]=).call(0, *intval).inspect
puts ia10.inspect
expect_raise("iarr_get_str")   { ia6.method(:[]).call("z") }
expect_raise("adapter_get_short") { ia6.method(:[]).call() }
# The `.to_proc` trampoline of a binop wrapper has the same operand parameter,
# so the zero-argument proc call must raise too instead of reading arr[0].
expect_raise("adapter_get_proc_short") { ia6.method(:[]).to_proc.call() }
puts ia6.inspect

# A rest target with parameters AFTER the rest (a post-rest positional, a
# declared keyword, or `**kwrest`) cannot ride the fixed `.call` cast: the rest
# arm builds only the parameters up to the rest, so a trailing one read an
# unpassed register (`def m(a, *r, c: 3); m.call(1, 2, 3)` answered garbage for
# `c`). The poly-slot route declines these; the bound-Method path declines too.
class RestTail
  def m(a, *r, c: 3) = [a, r, c]
  def p(a, *r, b) = [a, r, b]
  def req(a, *r, c:) = [a, r, c]
end
expect_nome("rest_kw_static")   { RestTail.new.method(:m).call(1, 2, 3) }
expect_nome("rest_post_static") { RestTail.new.method(:p).call(1, 2, 3) }
# Through Method#to_proc the trampoline binds a keyword after the rest from
# the call's keyword hash, so a required one the call omits is CRuby's
# `missing keyword` whatever the positional count. The post-rest positional
# still declines: the trampoline's fixed positional binding read the trailing
# parameter's register from args[] and handed an unset register to the
# callee, whose prologue rooted it -- a SIGSEGV.
expect_nome("rest_kw_toproc")      { RestTail.new.method(:req).to_proc.call(1, 2, 3) }
expect_nome("rest_kw_toproc_short") { RestTail.new.method(:req).to_proc.call(1) }
expect_nome("rest_post_toproc")   { RestTail.new.method(:p).to_proc.call(1, 2, 3) }
# A `**kwrest` after the rest is the same shape (the trailing slot has no
# fixed C cast).
class RestKwrest
  def m(a, *r, **kw) = [a, r, kw]
end
expect_nome("rest_kwrest_toproc") { RestKwrest.new.method(:m).to_proc.call(1, 2, 3) }

# Over-arity on a bound array operator is not modeled: the wrapper/adapter C
# cast has no slot for extra operands, so they are ignored where CRuby raises
# ArgumentError (`[]` takes 1..2, `[]=` takes 2..3); the in-range slice forms
# are ignored the same way.
ia7 = [1, 2, 3]
puts "iarr_get_over: #{ia7.method(:[]).call(0, 2, 3)}"
ia8 = [1, 2, 3]
puts "iarr_set_over: #{ia8.method(:[]=).call(0, 9, 8).inspect} #{ia8.inspect}"
# A multi-value `push` through a poly slot declines where the static route
# pushes both values.
ia9 = [1, 2]
expect_nome("iarr_poly_push_multi") { [ia9.method(:push)][0].call(8, 9) }
puts ia9.inspect


# A parameter default that WRITES a method-scope local the body READS cannot be
# answered from the bound call-site frame: the default runs there while the
# body reads its own zeroed slot, so `def m(a, c = (z = a + 1; z)); z; end`
# answered 0 where CRuby answers 6. The direct call is a C compile failure for
# the same shape; these two routes decline instead of answering the zero.
class DefaultBodyLocal
  def m(a, c = (z = a + 1; z)) = z
end
expect_nome("default_body_local_call")   { DefaultBodyLocal.new.method(:m).call(5) }
expect_nome("default_body_local_toproc") { DefaultBodyLocal.new.method(:m).to_proc.call(5) }

# A caller local spelled exactly like the frame's old rename prefix must not be
# captured by the callee-local declaration; the unique name now begins with an
# uppercase letter, which no Ruby local can.
class RenameSpell
  def m(a, c = (z = a + 1; z)) = [c]
end
_bm1_z = 100
puts RenameSpell.new.method(:m).call(5, _bm1_z).inspect

# A default-created local whose name overflows the rename table's source
# buffer is left unrenamed in BOTH the declaration and the default (a longer
# name used to declare lv_Bm1_<name> while the default read an undeclared
# lv_<name> -- a C compile failure).
class LongLocal
  def m(a, c = (zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz = a + 1; zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz)) = [c]
end
puts LongLocal.new.method(:m).call(5).inspect

# A PARAMETER name longer than the rename table's source buffer cannot ride the
# alias registration that lets a default read an earlier parameter at the call
# site. The old code truncated the source name but still declared the aliased
# temp, so a default referencing the parameter emitted the undeclared
# `lv_<name>` -- a C compile failure. Decline both routes instead.
class LongParam
  def m(aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa,
        b = aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa + 1) = [b]
end
expect_nome("long_param_call")   { LongParam.new.method(:m).call(5) }
expect_nome("long_param_toproc") { LongParam.new.method(:m).to_proc.call(5) }

# A keyword argument that names no declared keyword parameter must not bind to
# a positional one by name: CRuby sends it to `**kwrest`. When the trailing
# hash cannot be placed the bound `.call` cast declines, and with a declared
# keyword parameter before the kwrest the old code emitted an `sp_int`
# initialized from a hash pointer -- a C build failure (and without one it
# answered a mis-bound positional). A kwrest-only target whose keys are all
# unknown still maps the whole hash into its single `**kwrest` slot when the
# positional arguments already fill the parameters before it, and now raises
# CRuby's ArgumentError (not NoMethodError) when a required positional is
# missing or too many positionals are supplied (`method_call_count_violation`
# no longer skips kwrest targets).
class KwRest
  def d(a, k: 1, **kw) = [a, k, kw]
  def w(a, **kw) = [a, kw]
  def w2(a, b = 5, **kw) = [a, b, kw]
end
expect_nome("kwrest_unmatched")       { KwRest.new.method(:d).call(1, z: 2) }
expect_raise("kwrest_positional_name") { KwRest.new.method(:w).call(a: 2) }
puts KwRest.new.method(:w).call(1, z: 2).inspect
# A kwrest-only target whose positional parameters are not already filled by
# the call cannot route the trailing hash to its kwrest slot: the fixed
# positional fallback bound the hash to a scalar parameter and the generated C
# failed to compile (`def w(a, **kw); w.call(z: 2)`). A missing positional now
# raises CRuby's ArgumentError; the optional-gap shape declines.
expect_raise("kwrest_gap_call")     { KwRest.new.method(:w).call(z: 2) }
expect_nome("kwrest_gap_opt_call") { KwRest.new.method(:w2).call(1, z: 2) }
expect_raise("kwrest_gap2_call")   { KwRest.new.method(:w2).call(z: 2) }

# A `false` argument to an int-inferred parameter must decline on both the
# static and the generic-trampoline routes: the raw sp_int slot would be 0,
# which is a truthy Ruby Integer, so `x ? a : b` would answer the true branch
# where CRuby answers the false one.
class BoolArg
  def pick(x) = x ? "t" : "f"
end
BoolArg.new.pick(1)
expect_nome("bool_arg_call") { [BoolArg.new.method(:pick)][0].call(false) }
expect_nome("bool_arg_proc") { [BoolArg.new.method(:pick)][0].to_proc.call(false) }

# The proc ABI carries at most 16 positional slots. A statically-known target
# with MORE than 16 parameters cannot ride the per-site `.to_proc` trampoline:
# its call expression read `args[16]` past the caller's `(sp_int[16])` array
# (a garbage argument, or a crash for a pointer parameter) instead of raising.
# Both the non-splat and the splatted form decline, as does a rest target given
# more than 16 arguments (whose surplus the rest loop silently dropped). CRuby
# answers these; spinel's decline is the documented 16-slot ABI limit.
class ManyParams
  def m17(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17)
    a1 + a17
  end
  def rest(a, *r) = [a, r]
end
many = (1..17).to_a
expect_nome("toproc_many_params") { ManyParams.new.method(:m17).to_proc.call(*many) }
expect_nome("toproc_many_params_fixed") { ManyParams.new.method(:m17).to_proc.call(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17) }
many_rest = (1..20).to_a
expect_nome("toproc_rest_over") { ManyParams.new.method(:rest).to_proc.call(*many_rest) }

# A `**kwrest` target cannot ride the fixed positional `to_proc` cast: the proc
# ABI carries no keyword channel, so the bind==0 arm read an uninitialized
# register as the sp_SymPolyHash* and the callee dereferenced it -- a SIGSEGV.
# Decline with the same NoMethodError the rest-tail shapes use. (The direct
# `.call` supports the shape: see poly_method_return_kinds.rb.)
class KwRestProc
  def m(a, **k) = [a, k]
end
expect_nome("kwrest_toproc_empty") { KwRestProc.new.method(:m).to_proc.call(1) }
expect_nome("kwrest_toproc_kw")    { KwRestProc.new.method(:m).to_proc.call(1, z: 2) }

# A declared keyword parameter binds from the call's trailing keyword hash,
# which the trampoline takes off the positionals (the hash used to be bound
# to the next parameter's sp_int slot: `def m(a, b = a + 1, c: 3)` answered
# `[1, <garbage>, 3]` for `.to_proc.call(1, c: 5)`, and was then declined).
# A required keyword the call omits is CRuby's `missing keyword`.
class KwProc
  def opt(a, b = a + 1, c: 3) = [a, b, c]
  def rest(a, *r, c: 3) = [a, r, c]
  def req(a, c:) = [a, c]
end
# A target with no spare optional positional: the keyword hash is not
# counted as one, so the call binds.
class KwNoOptProc
  def m(a, c: 3) = [a, c]
end
puts KwProc.new.method(:opt).to_proc.call(1).inspect
expect_nome("toproc_opt_kw")   { KwProc.new.method(:opt).to_proc.call(1, c: 5) }
expect_raise("toproc_kw_no_opt") { KwNoOptProc.new.method(:m).to_proc.call(1, c: 9) }
expect_nome("toproc_rest_kw")  { KwProc.new.method(:rest).to_proc.call(1, c: 5) }
expect_nome("toproc_req_kw")   { KwProc.new.method(:req).to_proc.call(1, c: 9) }
expect_nome("toproc_req_nokw") { KwProc.new.method(:req).to_proc.call(1) }

# A class value that is not a statically-known constant
# (`self.class.method(:m)`) resolves no target, so the bind site stamps a NULL
# fn. Invoking it -- directly, through a poly slot, or through #to_proc -- must
# decline with NoMethodError rather than jump through NULL. CRuby answers this
# specific shape, so the decline is a documented limitation; the guarantee
# pinned here is that it raises instead of crashing.
class ClassValueTarget
  def self.cm(a) = a
  def direct = self.class.method(:cm).call(3)
  def direct_proc = self.class.method(:cm).to_proc.call(3)
  def poly = (a = [self.class.method(:cm)]; a[0].call(3))
  def poly_proc = (a = [self.class.method(:cm)]; a[0].to_proc.call(3))
end
expect_nome("class_value_call")     { ClassValueTarget.new.direct }
expect_nome("class_value_toproc")   { ClassValueTarget.new.direct_proc }
expect_nome("class_value_poly")     { ClassValueTarget.new.poly }
expect_nome("class_value_polyproc") { ClassValueTarget.new.poly_proc }
