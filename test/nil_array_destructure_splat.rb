# A nil Array the compiler reads on its own -- a multiple assignment, a
# destructuring parameter or block parameter, a pattern, the splat of a call or
# a rest parameter -- is read as the empty Array CRuby reads, not as a call on
# nil (#9347): the runtime functions those read through (sp_PolyArray_get among
# them) stay tolerant, and only their raising twins (sp_PolyArray_get_m) are
# called where the program calls the method.
F = ARGV.size > 5
def ia = F ? [1, 2] : nil
def pa = F ? [1, "a"] : nil
def sa = F ? ["a", "b"] : nil
def fa = F ? [1.5, 2.5] : nil
class O; end
def oa = F ? [O.new, O.new] : nil

def t(label)
  p [label, yield]
rescue NoMethodError => e
  p [label, e.message]
end

# multiple assignment
t(:ia) { a, b = ia; [a, b] }
t(:pa) { a, b = pa; [a, b] }
t(:sa) { a, b = sa; [a, b] }
t(:fa) { a, b = fa; [a, b] }
t(:oa) { a, b = oa; [a.nil?, b.nil?] }
t(:ia_rest) { a, *b = ia; [a, b] }
t(:pa_rest) { a, *b = pa; [a, b] }
t(:sa_pre) { *a, b = sa; [a, b] }
t(:oa_rest) { a, *b = oa; [a.nil?, b] }
t(:pa_mid) { a, *b, c = pa; [a, b, c] }
t(:nested) { a, (b, c) = 1, pa; [a, b, c] }

# destructuring parameters and block parameters
def dp((a, b)) = [a, b]
t(:dparam) { dp(pa) }
t(:dparam_o) { x, y = dp(oa); [x.nil?, y.nil?] }
t(:lambda) { ->((a, b)) { [a, b] }.call(pa) }
t(:block) { [[1, pa]].map { |a, (b, c)| [a, b, c] } }
t(:block_idx) { [pa].each_with_index.map { |(a, b), i| [a, b, i] } }

# a slot: a local, an instance variable, a global
x = pa
t(:local) { m, n = x; [m, n] }
$g = pa
t(:gvar) { m, n = $g; [m, n] }
class K
  def initialize(f) = (@a = [1, "x"] if f)
  def d = (a, b = @a; [a, b])
end
t(:ivar) { K.new(false).d }

# a pattern
t(:case_in) { case pa; in [a, b] then [a, b]; in nil then :nil; end }
t(:case_rest) { case pa; in [a, *r] then [a, r]; in nil then :nil; end }

# a rest built from the splat of a nil Array is empty
def r_all(*r) = r
def r_first(*r) = r.first
def r_last(*r) = r.last
def r_idx(*r) = r[0]
def r_size(*r) = r.size
def r_nil(*r) = r.nil?
def r_or(*r) = (r || [9])
def r_push(*r) = (r << 5; r)
def r_join(*r) = r.join("-")
def r_inc(*r) = r.include?(3)
def r_to_a(*r) = r.to_a
def r_destr(*r) = (a, b = r; [a, b])
def r_kw(*r, k: 1) = [r, k]
def r_ent(*r) = r.entries
t(:splat_all) { r_all(*pa) }
t(:splat_all_i) { r_all(*ia) }
t(:splat_all_s) { r_all(*sa) }
t(:splat_all_2) { r_all(1, *pa) }
t(:splat_first) { r_first(*pa) }
t(:splat_last) { r_last(*pa) }
t(:splat_idx) { r_idx(*pa) }
t(:splat_size) { r_size(*pa) }
t(:splat_nil) { r_nil(*pa) }
t(:splat_or) { r_or(*pa) }
t(:splat_push) { r_push(*pa) }
t(:splat_join) { r_join(*pa) }
t(:splat_inc) { r_inc(*pa) }
t(:splat_to_a) { r_to_a(*pa) }
t(:splat_destr) { r_destr(*pa) }
t(:splat_kw) { r_kw(*pa, k: 2) }
t(:splat_ent) { r_ent(*pa) }
t(:splat_send) { send(:r_first, *pa) }
t(:splat_meth) { method(:r_size).call(*pa) }
t(:splat_obj) { r_size(*oa) }
class A; def m(*r) = [r.first, r.size]; end
class B < A; def m(*r) = super; end
class C < A; def m(*r) = super(*r); end
class D < A; def m(...) = super(...); end
t(:super) { B.new.m(*pa) }
t(:super_args) { C.new.m(*pa) }
t(:super_fwd) { D.new.m(*pa) }
class E; define_method(:dm) { |*r| [r.first, r.size] }; end
t(:define_method) { E.new.dm(*pa) }
t(:proc) { proc { |*r| [r.first, r.size] }.call(*pa) }
def yy(x) = yield(*x)
t(:yield) { yy(pa) { |*r| [r.first, r.size] } }
t(:literal) { [*pa, 3] }
t(:literal_only) { [*ia] }
