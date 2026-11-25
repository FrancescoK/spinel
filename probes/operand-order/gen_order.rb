# Operand-order probe generator (matz/spinel#11506).
#
#   ruby gen_order.rb OUTDIR [--batch N] [--seed S] [--only SHAPE,..]
#
# Writes OUTDIR/b_NNN.rb (N cases a program) and OUTDIR/cases.tsv (id, shape,
# family key, the case's expression). Every case is a method c_ID that resets
# the shared state, evaluates one call shape whose operand slots are filled
# from a menu, and prints [id, answer.inspect, $t, victim]: the answer, the
# order the operands ran in ($t, each traced operand appends its tag), and
# the state of the variable the operands share.
#
# Case kinds, per shape:
#   order   every slot traces (`($t << k; LIT)`): the order the operands ran.
#   raise   slot j raises after tracing, the others trace: which ran.
#   effect  slot i reads the victim variable, slot j has an effect on it
#           (mut: changes it in place; reas: reassigns it; tos: an implicit
#           to_s that changes it), the other slots are literals. Routes say
#           where the victim lives and how the effect reaches it:
#             L  a local, effect inline     LP a local, effect via a proc
#             IV an ivar, effect inline     IM an ivar, effect via a method
#             GM a global, effect via a method
# Deterministic: the seed only shuffles the batching (cases are a full cross).

require "fileutils"

out = ARGV.shift or abort "usage: gen_order.rb OUTDIR [--batch N] [--seed S] [--only a,b]"
batch = 40
seed = 1
only = nil
while (a = ARGV.shift)
  case a
  when "--batch" then batch = Integer(ARGV.shift)
  when "--seed" then seed = Integer(ARGV.shift)
  when "--only" then only = ARGV.shift.split(",")
  else abort "unknown #{a}"
  end
end

# type -> [literal, initial value of a victim of the type]
LIT = {
  S: '+"qrs"', I: "2", A: "[1, 2, 3]", H: '{"ab" => 1}', K: "K.new(4)", R: "/b/", P: ":upcase"
}.freeze
INIT = { S: '+"ab"', I: "5", A: "[1, 2, 3]", H: '{"ab" => 1}', K: "K.new(3)" }.freeze
VNAME = { S: "s", I: "n", A: "a", H: "h", K: "o" }.freeze
# effect kind -> type -> code applied to the victim (VAR)
EFF = {
  mut: { S: 'VAR << "z"', A: "VAR << 9", H: 'VAR["k"] = 3', K: "VAR.v = 7" },
  reas: { S: 'VAR = +"WXYZ"', I: "VAR = 99", A: "VAR = [7]", H: 'VAR = {"zz" => 2}', K: "VAR = K.new(8)" }
}.freeze

# name, template (%0.. slots), slot types, note
SHAPES = [
  ["ucall2", "f_SS(%0, %1)", %i[S S]],
  ["ucall3", "f_SSS(%0, %1, %2)", %i[S S S]],
  ["ucall_ii", "f_II(%0, %1)", %i[I I]],
  ["ucall_ai", "f_AI(%0, %1)", %i[A I]],
  ["cmeth", "KK.mk(%0, %1)", %i[S S]],
  ["urecv", "%0.k(%1)", %i[K S]],
  ["str_center", "%0.center(%1, %2)", %i[S I S]],
  ["str_sub", "%0.sub(%1, %2)", %i[S S S]],
  ["str_incl", "%0.include?(%1)", %i[S S]],
  ["str_plus", "%0 + %1", %i[S S]],
  ["str_mul", "%0 * %1", %i[S I]],
  ["str_eq", "%0 == %1", %i[S S]],
  ["str_cmp", "%0 <=> %1", %i[S S]],
  ["str_app", "%0 << %1", %i[S S]],
  ["str_match", "%0 =~ %1", %i[S R]],
  ["str_idx", "%0[%1]", %i[S I]],
  ["fmt", 'format("%s-%s", %0, %1)', %i[S S]],
  ["int_plus", "%0 + %1", %i[I I]],
  ["int_lt", "%0 < %1", %i[I I]],
  ["int_clamp", "%0.clamp(%1 - 100, %2 + 100)", %i[I I I]],
  ["arr_plus", "%0 + %1", %i[A A]],
  ["arr_push", "%0.push(%1, %2)", %i[A I I]],
  ["arr_app", "%0 << %1", %i[A I]],
  ["arr_idx", "%0[%1]", %i[A I]],
  ["arr_aset", "%0[%1] = %2", %i[A I I]],
  ["arr_opasgn", "%0[%1] += %2", %i[A I I]],
  ["hash_idx", "%0[%1]", %i[H S]],
  ["hash_aset", "%0[%1] = %2", %i[H S I]],
  ["hash_orasgn", "%0[%1] ||= %2", %i[H S I]],
  ["hash_fetch", "%0.fetch(%1, %2)", %i[H S I]],
  ["attr_asgn", "%0.v = %1", %i[K I]],
  ["attr_opasgn", "%0.v += %1", %i[K I]],
  ["masgn", "(x1, x2 = %0, %1; [x1, x2])", %i[S S]],
  ["masgn_idx", "(%0[%1], y2 = %2, 8; [y2])", %i[A I I]],
  ["safe_nav", "%0&.center(%1, %2)", %i[S I S]],
  ["blockpass", "fb_S(%0, &%1)", %i[S P]],
  ["blockpass2", "fb_SS(%0, %1, &%2)", %i[S S P]],
  ["kwargs", "fk_SS(a: %0, b: %1)", %i[S S]],
  ["splat", "f_star(*%0, %1)", %i[A I]],
  ["defarg", "fdef_S(%0)", %i[S]],
  ["interp", '"#{%0}-#{%1}"', %i[S S]],
  ["interp_i", '"#{%0}-#{%1}"', %i[I I]],
  ["arr_lit", "[%0, %1]", %i[S S]],
  ["hash_lit", "{%0 => %1}", %i[S I]],
  ["and_or", "(%0 && %1)", %i[S S]],
  ["nested", "f_SS(%0.center(%1, %2), %3)", %i[S I S S]],
  # second set (gen2)
  ["send", "send(:f_SS, %0, %1)", %i[S S]],
  ["ucall_blk", "fy_SS(%0, %1) { |x, y| \"\#{x}|\#{y}\" }", %i[S S]],
  ["str_aset", "%0[%1] = %2", %i[S I S]],
  ["str_concat", "%0.concat(%1, %2)", %i[S S S]],
  ["str_insert", "%0.insert(%1, %2)", %i[S I S]],
  ["arr_unshift", "%0.unshift(%1, %2)", %i[A I I]],
  ["arr_fetch", "%0.fetch(%1, %2)", %i[A I I]],
  ["arr_lit_splat", "[*%0, %1]", %i[A I]],
  ["int_between", "%0.between?(%1, %2)", %i[I I I]],
  ["attr_read", "%0.v + %1", %i[K I]],
  ["urecv_attr_chain", "%0.k(%1).center(%2)", %i[K S I]],
  ["ternary_arg", "f_SS((%0 ? %1 : %2), %1)", %i[S S S]],
  ["str_eqq", "(%0 === %1)", %i[S S]],
  ["hash_aset_s", "%0[%1] = %2", %i[H S I]],
  ["local_orasgn_arg", "f_SS(%0, (qq ||= %1))", %i[S S]],
].freeze

ROUTES = %i[L LP IV IM GM].freeze

def vexpr(route, ty)
  v = VNAME[ty]
  case route
  when :L, :LP then v
  when :IV, :IM then "@#{v}"
  when :GM then "$#{v}"
  end
end

$methods = {}
$procs = nil

# The operand that has effect `eff` on the victim of type vty, held per
# `route`, in a slot of type sty, tagged k. Returns [operand text, prelude].
def effect_operand(route, eff, vty, sty, k)
  lit = LIT[sty]
  if eff == :mutret
    return nil unless sty == vty && EFF[:mut][vty]
    code = EFF[:mut][vty]
    v = vexpr(route, vty)
    case route
    when :L, :IV then return ["($t << #{k}; #{code.sub('VAR', v)}; #{v})", ""]
    when :LP then return ["g#{k}.call", "g#{k} = proc { $t << #{k}; #{code.sub('VAR', v)}; #{v} }; "]
    else
      name = "e_#{route.downcase}_mutret_#{vty}"
      $methods[name] ||= "def #{name}(k) = ($t << k; #{code.sub('VAR', v)}; #{v})"
      return ["#{name}(#{k})", ""]
    end
  end
  if eff == :tos
    return nil unless sty == :S && vty == :S && route == :GM
    return ['"#{TsG.new}"', ""]
  end
  code = EFF[eff][vty] or return nil
  case route
  when :L, :IV
    ["($t << #{k}; #{code.sub('VAR', vexpr(route, vty))}; #{lit})", ""]
  when :LP
    ["g#{k}.call", "g#{k} = proc { $t << #{k}; #{code.sub('VAR', vexpr(route, vty))}; #{lit} }; "]
  when :IM, :GM
    name = "e_#{route.downcase}_#{eff}_#{vty}_#{sty}"
    $methods[name] ||= "def #{name}(k) = ($t << k; #{code.sub('VAR', vexpr(route, vty))}; #{lit})"
    ["#{name}(#{k})", ""]
  end
end

cases = []
SHAPES.each do |name, tmpl, tys|
  next if only && !only.include?(name)
  n = tys.size
  fill = ->(ops) { ops.each_with_index.reduce(tmpl) { |t, (o, i)| t.gsub("%#{i}", o) } }
  # order
  cases << { shape: name, kind: "order", fam: "#{name}/order", route: :L, vty: :S,
             expr: fill.(tys.each_with_index.map { |t, i| "($t << #{i + 1}; #{LIT[t]})" }), pre: "" }
  # raise
  n.times do |j|
    ops = tys.each_with_index.map { |t, i| i == j ? "($t << #{i + 1}; rz; #{LIT[t]})" : "($t << #{i + 1}; #{LIT[t]})" }
    cases << { shape: name, kind: "raise", fam: "#{name}/raise@#{j}", route: :L, vty: :S, expr: fill.(ops), pre: "" }
  end
  # two: victim read at i, effects at j < k2 (mut, then reas)
  if n >= 3
    n.times do |i|
      vty = tys[i]
      next unless INIT.key?(vty)
      pos = (0...n).reject { |x| x == i }
      j, k2 = pos[0], pos[1]
      %i[L IM].each do |route|
        e1 = effect_operand(route, :mut, vty, tys[j], j + 1) or next
        e2 = effect_operand(route, :reas, vty, tys[k2], k2 + 1) or next
        ops = tys.each_with_index.map { |t, x| x == i ? vexpr(route, vty) : x == j ? e1[0] : x == k2 ? e2[0] : LIT[t] }
        cases << { shape: name, kind: "two", fam: "#{name}/v#{i}two", route: route, vty: vty,
                   expr: fill.(ops), pre: e1[1] + e2[1] }
      end
    end
  end
  # effect
  n.times do |i|
    vty = tys[i]
    next unless INIT.key?(vty)
    n.times do |j|
      next if i == j
      ROUTES.each do |route|
        %i[mut reas tos mutret].each do |eff|
          eo = effect_operand(route, eff, vty, tys[j], j + 1) or next
          ops = tys.each_with_index.map { |t, x| x == i ? vexpr(route, vty) : x == j ? eo[0] : LIT[t] }
          cases << { shape: name, kind: "effect", fam: "#{name}/v#{i}e#{j}/#{eff}", route: route, vty: vty,
                     expr: fill.(ops), pre: eo[1] }
        end
      end
    end
  end
end

# Hand-written cases: Matz's left-over item 2 and the ledger repros.
HAND = [
  ["matz2a", "[s].first + (s << \"3\")", :S, :L],
  ["matz2b", "\"\#{s.upcase!.to_s}-\#{s << \"!\"}\"", :S, :L],
  ["bp_nil", "f_bpn(1, &($t << 1; nil))", :S, :L],
  ["bp_nil_m", "f_bpn(2, &e_nilblk(1))", :S, :L],
  ["match_im", "@s =~ e_im_reas_S_R(2)", :S, :IM],
  ["bp_lambda_via_call", "fb_S(+\"q\", &e_lm(1))", :S, :L],
]
$methods["e_im_reas_S_R"] = 'def e_im_reas_S_R(k) = ($t << k; @s = +"WXYZ"; /b/)'
$methods["e_nilblk"] = "def e_nilblk(k) = ($t << k; nil)"
$methods["e_lm"] = "def e_lm(k) = ($t << k; LM)"
HAND.each do |nm, e, vty, route|
  cases << { shape: "hand", kind: "hand", fam: "hand/#{nm}", route: route, vty: vty, expr: e, pre: "" }
end

cases.each_with_index { |c, i| c[:id] = i + 1 }

PRELUDE = <<~'RB'
  $t = [0]
  LM = ->(z) { "#{z}!" }
  $s = +"ab"; $n = 5; $a = [1, 2, 3]; $h = {"ab" => 1}
  class K
    attr_accessor :v
    def initialize(v) = (@v = v)
    def k(x) = "#{@v}|#{x}"
    def inspect = "K(#{@v})"
  end
  $o = K.new(3)
  class KK
    def self.mk(a, b) = "#{a}|#{b}"
  end
  class TsG
    def to_s = ($t << 9; $s << "zz"; "o")
  end
  def rz = raise(IOError, "x")
  def f_SS(a, b) = "#{a}|#{b}"
  def f_SSS(a, b, c) = "#{a}|#{b}|#{c}"
  def f_II(a, b) = "#{a}|#{b}"
  def f_AI(a, b) = "#{a.inspect}|#{b}"
  def f_star(*r) = r.inspect
  def fb_S(a, &b) = b.call(a)
  def fb_SS(a, c, &b) = b.call(a) + c
  def fk_SS(a:, b:) = "#{a}|#{b}"
  def fdef_S(a, b = $t.size) = "#{a}|#{b}"
  def f_bpn(a, &b) = [a, block_given?]
  def fy_SS(a, b) = yield(a, b)
RB

def case_src(c)
  route = c[:route]
  vty = c[:vty]
  init = INIT.map do |ty, v|
    case route
    when :L, :LP then "#{VNAME[ty]} = #{v}"
    when :IV, :IM then "@#{VNAME[ty]} = #{v}"
    when :GM then "$#{VNAME[ty]} = #{v}"
    end
  end
  vic = vexpr(route, vty)
  <<~RB
    def c_#{c[:id]}
      $t = []; qq = nil; #{init.join('; ')}
      #{c[:pre]}r = begin; (#{c[:expr]}).inspect; rescue IOError; "raised"; end
      p [#{c[:id]}, r, $t, #{vic}]
    end
    begin; c_#{c[:id]}; rescue => e; p [#{c[:id]}, :exc, e.class]; end
  RB
end

FileUtils.mkdir_p(out)
Dir.glob(File.join(out, "b_*.rb")).each { |f| File.delete(f) }
order = cases.shuffle(random: Random.new(seed))
order.each_slice(batch).with_index do |sl, bi|
  src = PRELUDE + $methods.values.join("\n") + "\n" + sl.map { |c| case_src(c) }.join
  File.write(File.join(out, format("b_%03d.rb", bi)), src)
end
File.open(File.join(out, "cases.tsv"), "w") do |f|
  cases.each { |c| f.puts [c[:id], c[:shape], c[:kind], c[:fam], c[:route], c[:pre] + c[:expr]].join("\t") }
end
# one-case program writer for the runner's bisection
File.write(File.join(out, "prelude.rb"), PRELUDE + $methods.values.join("\n") + "\n")
File.open(File.join(out, "case_src.tsv"), "w") { |f| cases.each { |c| f.puts [c[:id], [case_src(c)].pack("m0")].join("\t") } }
warn "#{cases.size} cases, #{(cases.size + batch - 1) / batch} programs"
