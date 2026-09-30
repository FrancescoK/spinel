# A block parameter some site passes an explicit nil beside an Integer --
# `yield 1; yield nil`, `yield(*[1, nil])`, `pr.call(nil)` next to
# `pr.call(1)`, a `= nil` default -- stays an Integer slot holding the nil
# sentinel, so every binder has to write the sentinel for the nil, and
# every read has to answer for it: inspect, nil?, truth, interpolation, a
# boxed container, a Hash key, `Integer ===`, arithmetic raising CRuby's
# error, a comparison, a case arm, a lambda capturing it, `||=`. A proc
# reads a nil passed through a call its typing cannot see (an alias, `===`)
# as nil, not 0, and a local copied from a parameter a call leaves out is
# nil too.

def two = (yield 1; yield nil)
def lit = (yield(*[1, nil]); yield(*[nil, 2]))
def gath(xs) = yield(*xs, nil)
def opt = (yield 1; yield 1, 2; yield 1, nil)

two do |a|
  p [a, a.nil?, (a ? :t : :f), "#{a}", [a], { a => 1 }, Integer === a, a.to_i]
  p [(a + 1 rescue $!.class), (1 + a rescue $!.class), (a > 0 rescue $!.class), (1 < a rescue $!.class)]
  case a
  when nil then p :nil_arm
  when Integer then p :int_arm
  end
end
two { |a| q = -> { a }; p q.call }
two { |a| a ||= 7; p a }
two { p [_1, _1.nil?, { _1 => 1 }, Integer === _1, (_1 + 1 rescue $!.class)] }
two { p [it, it.nil?, [it], Integer === it, (1 + it rescue $!.class)] }

# a splat of an array literal holding a nil, and a nil gathered after a splat
lit do |a, b|
  p [a, b, b.nil?, (b ? :t : :f), { b => 1 }, Integer === b, (b + 1 rescue $!.class), (1 + b rescue $!.class)]
  p(case b when nil then :nil_arm when Integer then :int_arm end)
end
lit { |a, b| q = -> { b }; p q.call }
lit { |a, b| b ||= 7; p [a, b] }
lit { |a, b = 5| p [a, b, b.nil?, { b => 1 }, Integer === b, (b + 1 rescue $!.class)] }
gath([1]) { |a, b| p [a, b, b.nil?, { b => 1 }, Integer === b, (b > 0 rescue $!.class)] }
gath([]) { |a, b| p [a, b, a.nil?, { a => 1 }, Integer === a, (1 < a rescue $!.class)] }

# an optional whose default is nil
opt do |a, b = nil|
  p [a, b, b.nil?, (b ? :t : :f), [b], { b => 1 }, Integer === b, (b + 1 rescue $!.class)]
  p(case b when nil then :nil_arm when Integer then :int_arm end)
end
opt { |a, b = nil| b ||= 7; p b }

# instance_exec with a splat, directly and through a trampoline
class Box
  def initialize(v) = @v = v
  def all(*a, &b) = instance_exec(*a, &b)
end
Box.new(0)
o = Box.new(9)
o.instance_exec(*[1, nil]) { |a, b| p [a, b, b.nil?, { b => 1 }, Integer === b, (b + 1 rescue $!.class), @v] }
o.instance_exec(*[nil, 2]) { |a, b| p [a, b, a.nil?, { a => 1 }, Integer === a, (1 + a rescue $!.class), @v] }
o.all(*[1, nil]) { |a, b| p [a, b, b.nil?, { b => 1 }, Integer === b, (b > 0 rescue $!.class), @v] }
o.all(*[nil, 2]) { |a, b| p [a, b, a.nil?, { a => 1 }, (case a when nil then :nil_arm end), @v] }

# a block called through its &block
def cb(&b) = (b.call(1); b.call(nil))
cb do |a|
  p [a, a.nil?, (a ? :t : :f), [a], { a => 1 }, Integer === a]
  p [(a + 1 rescue $!.class), (1 + a rescue $!.class), (a > 0 rescue $!.class)]
  p(case a when nil then :nil_arm when Integer then :int_arm end)
end
cb { |a| q = -> { a }; p q.call }
cb { |a| a ||= 7; p a }

# a proc and a lambda called with an Integer and with nil
pr = proc do |a|
  p [a, a.nil?, (a ? :t : :f), [a], { a => 1 }, Integer === a]
  p [(a + 1 rescue $!.class), (1 + a rescue $!.class), (1 < a rescue $!.class)]
  p(case a when nil then :nil_arm when Integer then :int_arm end)
end
pr.call(1)
pr.call(nil)
la = ->(a) { p [a, a.nil?, { a => 1 }, Integer === a, (a + 1 rescue $!.class)] }
la.(3)
la.(nil)
pc = proc { |a| q = -> { a }; p q.call }
pc.call(1)
pc.call(nil)
po = proc { |a| a ||= 7; p a }
po.call(1)
po.call(nil)

# a nil passed through a call the Integer's typing cannot see: an alias,
# `===`, `to_proc`
al = proc { |a, b| p [a, b, a.nil?, Integer === a, { a => 1 }, (a + 1 rescue $!.class)] }
al.call(1, 2)
m = al
m.call(nil, 3)
al === nil
al.to_proc.call(nil, 4)

# a local copied from a proc parameter a call leaves out
cp = proc do |a, b|
  x = b
  p [x, x.nil?, Integer === x, x.is_a?(Integer), { x => 1 }]
  p(case x when Integer then :int_arm when nil then :nil_arm end)
end
cp.call(1)
cp.call(1, 2)

# a recursive yielder, which runs its block as a proc
def walk(n, &b)
  return (yield 1; yield nil) if n <= 0
  walk(n - 1) { |x| yield x }
end
walk(2) do |a|
  p [a, a.nil?, (a ? :t : :f), [a], { a => 1 }, Integer === a, (a + 1 rescue $!.class)]
  p(case a when nil then :nil_arm when Integer then :int_arm end)
end
walk(1) { |a| q = -> { a }; p q.call }
walk(1) { |a| a ||= 7; p a }
def walk_opt(n, &b)
  return (yield 1; yield 1, 2) if n <= 0
  walk_opt(n - 1) { |x, y = nil| yield x, y }
end
walk_opt(1) { |a, b = nil| p [a, b, b.nil?, { b => 1 }, Integer === b, (b + 1 rescue $!.class)] }

# a value only typed nil is no literal: a Struct member nothing but the
# constructor's nil set, or a reader of an ivar left nil, may be typed
# otherwise a round later, so the parameter it reaches beside an Integer
# stays boxed
part = Struct.new :a, :b
r = part.new(1)
p r.entries, r.map { |e| e }, r.select { |e| true }
class Z
  def initialize = @z = nil
  def z = @z
end
zz = Z.new
pz = proc { |a| p [a, a.nil?, Integer === a] }
pz.call(nil)
pz.call(1)
pz.call(zz.z)
