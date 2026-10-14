# Under --share-strings (#6765), a method whose tail is a boxed `x || y` or
# `x && y` with an operand that is a builtin call answering its receiver
# (`s.itself`, `s.then { |x| x }`, `s.tap { }`, `s.yield_self { |x| x }`,
# `+s`, a bang, `s << x`, `s.concat(x)`, `s.replace(x)`) answers
# the receiver's String itself, as CRuby 4.0 does. The operand was boxed from
# its bytes, which hold no handle, and the caller got a copy a change in
# place never reached. A user call answering the String was boxed by the
# handle it publishes; the builtin is now boxed by the handle its receiver
# is. The same holds for such a call in an arm of a conditional, a `case` or
# a `begin` that is an operand. A call over an instance variable and over a
# reader method are both covered, on either side of the `||` or `&&`, and so
# is a chain of such calls over an instance variable (`@s.upcase!.itself`,
# `@s.itself.tap { }`), whose bytes built the box.
class LtbApp
  def initialize(s, t)
    @s = s
    @t = t
  end

  def gs = @s

  def itself_l(v) = @s.itself || v
  def then_l(v) = @s.then { |x| x } || v
  def tap_l(v) = @s.tap {} || v
  def tap_blk_l(v) = @s.tap { |z| z << "" } || v
  def yself_l(v) = @s.yield_self { |x| x } || v
  def uplus_l(v) = (+@s) || v
  def bang_l(v) = @s.upcase! || v
  def append_l(v) = (@s << "") || v
  def concat_l(v) = @s.concat("") || v
  def replace_l(v) = @s.replace(@s) || v

  def itself_and(v) = v && @s.itself
  def tap_and(v) = v && @s.tap {}
  def bang_and(v) = v && @s.upcase!
  def itself_or_r(v) = v || @s.itself
  def both(v) = @s.itself && @s.itself

  def gs_itself(v) = gs.itself || v
  def gs_then(v) = gs.then { |x| x } || v
  def gs_bang(v) = gs.upcase! || v

  def chain_itself(v) = @s.itself.itself || v
  def chain_bang(v) = @s.upcase!.itself || v
  def chain_tap(v) = @s.itself.tap {} || v
  def chain_cond(v) = (v ? @s.upcase!.itself : @t) || v
  def nested(v) = (@s.itself || @t) || v

  def cond_arm(v) = (v ? @s.itself : @t) || v
  def cond_tap(v) = (v ? @s.tap {} : @t) || v
  def cond_bang(v) = (v ? @s.upcase! : @t) || v
  def case_arm(v) = (case v when 1 then @s.itself else @t end) || v
  def case_tap(v) = (case v when 1 then @s.tap {} else @t end) || v
  def begin_arm(v) = (begin; @s.itself; end) || v
  def begin_then(v) = (begin; @s.then { |x| x }; end) || v
  def and_arm(v) = (@s.itself && @t) || v
end

def pass(x) = x

def check(label)
  a = +"ab"
  a << "c"
  b = +"pq"
  b << "r"
  y = pass(yield(LtbApp.new(a, b)))
  a << "!" unless a.frozen?
  p [label, y, y.equal?(a), y.equal?(b)]
end

check(:itself_l) { |o| o.itself_l(1) }
check(:then_l) { |o| o.then_l(1) }
check(:tap_l) { |o| o.tap_l(1) }
check(:tap_blk_l) { |o| o.tap_blk_l(1) }
check(:yself_l) { |o| o.yself_l(1) }
check(:uplus_l) { |o| o.uplus_l(1) }
check(:bang_l) { |o| o.bang_l(1) }
check(:append_l) { |o| o.append_l(1) }
check(:concat_l) { |o| o.concat_l(1) }
check(:replace_l) { |o| o.replace_l(1) }

check(:itself_and) { |o| o.itself_and(1) }
check(:tap_and) { |o| o.tap_and(1) }
check(:bang_and) { |o| o.bang_and(1) }
check(:itself_or_r) { |o| o.itself_or_r(nil) }
check(:both) { |o| o.both(1) }

check(:gs_itself) { |o| o.gs_itself(1) }
check(:gs_then) { |o| o.gs_then(1) }
check(:gs_bang) { |o| o.gs_bang(1) }

check(:chain_itself) { |o| o.chain_itself(1) }
check(:chain_bang) { |o| o.chain_bang(1) }
check(:chain_tap) { |o| o.chain_tap(1) }
check(:chain_cond) { |o| o.chain_cond(true) }
check(:nested) { |o| o.nested(1) }

check(:cond_arm) { |o| o.cond_arm(true) }
check(:cond_tap) { |o| o.cond_tap(true) }
check(:cond_bang) { |o| o.cond_bang(true) }
check(:case_arm) { |o| o.case_arm(1) }
check(:case_tap) { |o| o.case_tap(1) }
check(:begin_arm) { |o| o.begin_arm(1) }
check(:begin_then) { |o| o.begin_then(1) }
check(:and_arm) { |o| o.and_arm(1) }

# the other arm wins: its own String, not the receiver's
check(:cond_other) { |o| o.cond_arm(nil) }
check(:case_other) { |o| o.case_arm(2) }
check(:and_other) { |o| o.itself_and(nil) }
check(:cond_none) { |o| o.cond_arm(false) }
