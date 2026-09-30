# A block parameter bound Floats and, at some site, nothing (`yield(*xs)` of
# a short array, a gathered splat) or a literal nil (`yield 1.5; yield nil`,
# `yield(*[1.5, nil])`, a `= nil` default, `pr.call(nil)` beside
# `pr.call(1.5)`) stays a Float slot holding the nil sentinel, as an
# Integer one does. So every binder has to write the sentinel for the nil,
# and every read has to answer for it: inspect, nil?, truth,
# interpolation, a boxed container, a Hash key, `Float ===`, arithmetic
# raising CRuby's error, a comparison, a case arm, a lambda capturing it,
# `||=`. A proc reads a nil passed through a call its typing cannot see (an
# alias, `===`, `to_proc`) as nil, not 0.0, and a local copied from a
# parameter a call leaves out is nil too.

def spread(xs) = yield(*xs)
def gath(xs) = yield(*xs, nil)
def two = (yield 1.5; yield nil)
def lit = (yield(*[1.5, nil]); yield(*[nil, 2.5]))
def opt = (yield 1.5; yield 1.5, 2.5; yield 1.5, nil)

# a value missing
spread([1.5]) do |a, b|
  p [a, b, b.nil?, b.inspect, b == nil, (b ? :t : :f), "b=#{b}.", b.to_s]
  p [(b + 1.0 rescue $!.class), (1.0 + b rescue $!.class), (b > 0.0 rescue $!.class), (1.0 < b rescue $!.class)]
  p [[b], { b => 1 }, Float === b, NilClass === b, b.is_a?(Float)]
  p(case b when nil then :nil_arm when Float then :float_arm end)
  p(case b when Float then :float_arm else :else_arm end)
end
spread([2.5]) { |a, b| q = -> { b }; p q.call }
spread([2.5]) { |a, b| b ||= 7.5; p [a, b] }
spread([]) { |a, b| p [a, b] }
spread([3.5, 4.0]) { |a, b| p a * b }
gath([]) { |a, b| p [a, b, a.nil?, { a => 1 }, Float === a, (1.0 < a rescue $!.class)] }
gath([1.5]) { |a, b| p [a, b, b.nil?, { b => 1 }, Float === b, (b > 0.0 rescue $!.class)] }

# a literal nil
two do |a|
  p [a, a.nil?, (a ? :t : :f), "#{a}", a.inspect, [a], { a => 1 }, Float === a]
  p [(a + 1.0 rescue $!.class), (1.0 + a rescue $!.class), (a > 0.0 rescue $!.class), (1.0 < a rescue $!.class)]
  p(case a when nil then :nil_arm when Float then :float_arm end)
end
two { |a| q = -> { a }; p q.call }
two { |a| a ||= 7.5; p a }
two { p [_1, _1.nil?, { _1 => 1 }, Float === _1, (_1 + 1.0 rescue $!.class)] }
two { p [it, it.nil?, [it], Float === it, (1.0 + it rescue $!.class)] }

# a splat of an array literal holding a nil
lit do |a, b|
  p [a, b, b.nil?, (b ? :t : :f), { b => 1 }, Float === b, (b + 1.0 rescue $!.class), (1.0 + b rescue $!.class)]
  p(case b when nil then :nil_arm when Float then :float_arm end)
end
lit { |a, b| q = -> { b }; p q.call }
lit { |a, b| b ||= 7.5; p [a, b] }
lit { |a, b = 5.5| p [a, b, b.nil?, { b => 1 }, Float === b, (b + 1.0 rescue $!.class)] }

# an optional whose default is nil
opt do |a, b = nil|
  p [a, b, b.nil?, (b ? :t : :f), [b], { b => 1 }, Float === b, (b + 1.0 rescue $!.class)]
  p(case b when nil then :nil_arm when Float then :float_arm end)
end
opt { |a, b = nil| b ||= 7.5; p b }

# instance_exec with a splat, directly and through a trampoline
class Box
  def initialize(v) = @v = v
  def all(*a, &b) = instance_exec(*a, &b)
  def one(x, &b) = instance_exec(x, &b)
end
Box.new(0)
o = Box.new(9)
short = [1.5]
o.instance_exec(*short) { |a, b| p [a, b, b.nil?, { b => 1 }, Float === b, @v] }
o.instance_exec(*[1.5, nil]) { |a, b| p [a, b, b.nil?, { b => 1 }, Float === b, (b + 1.0 rescue $!.class), @v] }
o.instance_exec(*[nil, 2.5]) { |a, b| p [a, b, a.nil?, { a => 1 }, Float === a, (1.0 + a rescue $!.class), @v] }
o.all(*short) { |a, b| p [a, b, b.nil?, @v] }
o.all(*[1.5, nil]) { |a, b| p [a, b, b.nil?, { b => 1 }, Float === b, (b > 0.0 rescue $!.class), @v] }
o.one(4.5) { |a, b| p [a, b, b.nil?, @v] }

# a block called through its &block
def call_it(xs, &b) = b.call(*xs)
call_it([3.5]) { |a, b| p [a, b, b.nil?, { b => 1 }, Float === b] }
call_it([3.5, 4.0]) { |a, b| p a + b }
def cb(&b) = (b.call(1.5); b.call(nil))
cb do |a|
  p [a, a.nil?, (a ? :t : :f), [a], { a => 1 }, Float === a]
  p [(a + 1.0 rescue $!.class), (1.0 + a rescue $!.class), (a > 0.0 rescue $!.class)]
  p(case a when nil then :nil_arm when Float then :float_arm end)
end
cb { |a| q = -> { a }; p q.call }
cb { |a| a ||= 7.5; p a }

# a proc and a lambda called with a Float and with nil
pr = proc do |a|
  p [a, a.nil?, (a ? :t : :f), [a], { a => 1 }, Float === a, "#{a}"]
  p [(a + 1.0 rescue $!.class), (1.0 + a rescue $!.class), (1.0 < a rescue $!.class)]
  p(case a when nil then :nil_arm when Float then :float_arm end)
end
pr.call(1.5)
pr.call(nil)
la = ->(a) { p [a, a.nil?, { a => 1 }, Float === a, (a + 1.0 rescue $!.class)] }
la.(3.5)
la.(nil)
pc = proc { |a| q = -> { a }; p q.call }
pc.call(1.5)
pc.call(nil)
po = proc { |a| a ||= 7.5; p a }
po.call(1.5)
po.call(nil)

# a nil passed through a call the Float's typing cannot see: an alias,
# `===`, `to_proc`
al = proc { |a, b| p [a, b, a.nil?, Float === a, { a => 1 }, (a + 1.0 rescue $!.class)] }
al.call(1.5, 2.5)
m = al
m.call(nil, 3.5)
al === nil
al.to_proc.call(nil, 4.5)

# a local copied from a proc parameter a call leaves out
cp = proc do |a, b|
  x = b
  p [x, x.nil?, Float === x, x.is_a?(Float), { x => 1 }]
  p(case x when Float then :float_arm when nil then :nil_arm end)
end
cp.call(1.5)
cp.call(1.5, 2.5)

# a recursive yielder, which runs its block as a proc
def walk(n, &b)
  return (yield 1.5; yield nil) if n <= 0
  walk(n - 1) { |x| yield x }
end
walk(2) do |a|
  p [a, a.nil?, (a ? :t : :f), [a], { a => 1 }, Float === a, (a + 1.0 rescue $!.class)]
  p(case a when nil then :nil_arm when Float then :float_arm end)
end
walk(1) { |a| q = -> { a }; p q.call }
walk(1) { |a| a ||= 7.5; p a }
def walk_opt(n, &b)
  return (yield 1.5; yield 1.5, 2.5) if n <= 0
  walk_opt(n - 1) { |x, y = nil| yield x, y }
end
walk_opt(1) { |a, b = nil| p [a, b, b.nil?, { b => 1 }, Float === b, (b + 1.0 rescue $!.class)] }

# an Integer and a Float into one parameter stay apart: neither is read
# as the other
def mix = (yield 1; yield 2.5; yield nil)
mix { |a| p [a, a.class] }
def mixs(xs) = yield(*xs)
mixs([1, 2.5]) { |a, b| p [a, b] }
pm = proc { |a| p [a, a.class] }
pm.call(1)
pm.call(2.5)
pm.call(nil)
