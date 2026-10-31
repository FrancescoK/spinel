# A call by name reaches the defs of that name that can take its argument
# count. When every argument is a plain positional expression the count is
# known, and a def that needs more positionals, or takes fewer and has no
# rest, is no target of the call; a splat, a keyword hash, `&blk` or `...`
# can change the count at run time and reach every def of the name as before.
# Names reached any other way (send with a name or arguments chosen at run
# time, method(:m), an alias, a Symbol to_proc, super) keep every arity.
#
# `refused` is a def the compiler would refuse to build (a define_method whose
# name is not literal). Its name is called below only with a count it cannot
# take, so it is never built and the program compiles.

# a 2-parameter def and a refusal behind it, called through a 0-argument call
def refused(a, b)
  o = Object.new
  class << o; define_method(a) { b }; end
end
class Plain; def refused = :zero; end
p Plain.new.refused

# the accepted range: required, optional, rest and post parameters
class Range1
  def opt(a, b = 2) = [:opt, a, b]
  def rest(a, *r) = [:rest, a, r]
  def post(a, b = 0, *r, z) = [:post, a, b, r, z]
  def kw(a, k: 1) = [:kw, a, k]
  def kwrest(a, **o) = [:kwrest, a, o]
  def none = :none
end
class Range2
  def opt(a, b, c) = [:opt3, a, b, c]
  def rest(a, b, c, d) = [:rest4, a, b, c, d]
  def post(a) = [:post1, a]
  def kw(a, b) = [:kw2, a, b]
  def kwrest(a, b) = [:kwrest2, a, b]
  def none(a) = [:none1, a]
end
r1 = Range1.new
r2 = Range2.new
p r1.opt(1), r1.opt(1, 5)
p r1.rest(1), r1.rest(1, 2, 3)
p r1.post(1, 2), r1.post(1, 2, 3), r1.post(1, 2, 3, 4, 5)
p r1.kw(1), r1.kw(1, k: 5)
p r1.kwrest(1), r1.kwrest(1, x: 2)
p r1.none
p r2.opt(1, 2, 3), r2.rest(1, 2, 3, 4), r2.post(7), r2.kw(1, 2), r2.kwrest(1, 2), r2.none(3)

# the same name in classes of different arities, each reached by its own call
class P1; def go(x) = [:p, x]; end
class Q1; def go(x, y) = [:q, x, y]; end
class R1; def go = [:r]; end
def run1(o) = o.go(1)
def run2(o) = o.go(1, 2)
def run0(o) = o.go
p run1(P1.new), run2(Q1.new), run0(R1.new)

# a splat, a forwarded `...` and a block argument leave the count open
class S2; def two(a, b) = [:two, a, b]; end
class S1; def two(a) = [:one, a]; end
class S0; def two = :zero; end
args = [1, 2]
p S2.new.two(*args)
args = [3]
p S1.new.two(*args)
args = []
p S0.new.two(*args)
def fwd(o, ...) = o.two(...)
p fwd(S2.new, 4, 5), fwd(S0.new)
class SB; def blk(&b) = b.call; end
pr = proc { 6 }
p SB.new.blk(&pr)

# send, public_send and method keep every arity
class T2; def t(a, b) = [:two, a, b]; end
class T0; def t = :zero; end
class T1; def t(a) = [:one, a]; end
sp = [1, 2]
p T2.new.send(:t, *sp), T0.new.public_send(:t), T1.new.__send__(:t, 4)
nm = :t
p T2.new.send(nm, 1, 2), T1.new.send(nm, 3)
m = T2.new.method(:t)
p m.call(5, 6), m.arity
p T2.instance_method(:t).bind(T2.new).call(7, 8)
p T0.new.t

# an alias or alias_method of a def keeps it for the alias's calls
class Al
  def orig(a, b) = [:orig, a, b]
  alias via orig
  alias_method :via2, :orig
end
class Al0; def via = :zero; def via2 = :zero2; end
p Al.new.via(1, 2), Al.new.via2(3, 4), Al0.new.via, Al0.new.via2

# a Symbol to_proc calls with no arguments
class Sy0; def sy = :zero; end
class Sy1; def sy(a) = [:one, a]; end
p [Sy0.new].map(&:sy)
p Sy1.new.sy(2)

# a private def called with an explicit self
class Pv
  def pub = self.sec(1, 2)
  private
  def sec(a, b) = [:sec, a, b]
end
class Pv1; def sec(a) = [:other, a]; end
p Pv.new.pub, Pv1.new.sec(5)

# super reaches the parent's def of another arity
class Par; def sup(a, b) = [:par, a, b]; end
class Chi < Par
  def sup(a) = super(a, 10)
end
class Zs < Par
  def sup(a, b)
    super
  end
end
class Zo; def sup = :zero; end
p Chi.new.sup(1), Zs.new.sup(2, 3), Zo.new.sup

# a module's def reached through super from an including class
module Loud
  def speak(a) = super(a, 1) + [:loud]
end
class Animal; def speak(a, b) = [:animal, a, b]; end
class Dog < Animal; include Loud; end
class Cat; def speak = :meow; end
p Dog.new.speak(5), Cat.new.speak

# a prepended module whose def calls the class's def of another arity
module Wrap; def hi(x) = [:wrap, super(x, 2)]; end
class Kp
  prepend Wrap
  def hi(x, y) = [:k, x, y]
end
class Jp; def hi = :jay; end
p Kp.new.hi(1), Jp.new.hi

# a call from a block that a method yields to
class Y2; def yy(a, b) = [:two, a, b]; end
class Y1; def yy(a) = [:one, a]; end
def twice = yield(Y1.new)
p(twice { |o| o.yy(7) })
p Y2.new.yy(1, 2)

# operators, an index write and an attribute write count their operands
class Vec
  attr_reader :x
  def initialize(x) = @x = x
  def +(o) = Vec.new(@x + o.x)
  def -@ = Vec.new(-@x)
  def [](i) = @x * i
  def []=(i, v)
    @x = i * v
  end
  def x=(v)
    @x = v
  end
end
class Wv
  def +(a, b) = :bad
  def [](a, b) = :bad2
  def []=(a)
    :bad3
  end
end
v = Vec.new(2)
p((v + Vec.new(3)).x, (-v).x, v[4])
v[2] = 5
p v.x
v.x = 7
p v.x

# a call whose count no def of the name takes raises ArgumentError. The def a
# call binds to by its receiver's class is built whatever the count: a typed
# receiver, self, a class method and a top-level def are all called.
def top1(a, b) = [:top, a, b]
class Wrong
  def wr(a, b) = [:two, a, b]
  def self_wr = wr(1)
  def self.sm(a, b) = [:sm, a, b]
  def self.go = sm(1)
end
class Wrong0; def wr = :zero; end
class Wrong3; def wr(a, b, c) = [:three, a, b, c]; end
def try_it(label)
  yield
rescue ArgumentError => e
  puts "#{label}: #{e.message}"
end
def try_wr(o)
  o.wr
rescue ArgumentError => e
  e.class
end
p try_wr(Wrong.new), try_wr(Wrong0.new)
w = Wrong.new
try_it(:typed) { w.wr }
try_it(:self) { w.self_wr }
try_it(:cmethod) { Wrong.go }
try_it(:top) { top1(1) }
try_it(:poly) { [Wrong.new, Wrong3.new].each { |o| o.wr(1) } }
kls = Wrong
try_it(:class_value) { kls.sm(1) }

# the super of a def a wrong count binds is reached though the count's mark was
# first seen at a call of another def: a parent, an included module, a
# prepended module and a class method, with a typed or a boxed receiver
class SwA; def sw(a, b) = a + b; end
class SwB < SwA; def sw = super(1, 2); end
class SwC; def sw(a) = a; end
module SwM; def swm(a, b) = [:m, a, b]; end
class SwMB; include SwM; def swm = super(1, 2); end
class SwMC; def swm(a) = a; end
module SwP; def swp = super(1, 2); end
class SwPB; prepend SwP; def swp(a, b) = a + b; end
class SwPC; def swp(a) = a; end
class SwKA; def self.swk(a, b) = a + b; end
class SwKB < SwKA; def self.swk = super(1, 2); end
class SwKC; def self.swk(a) = a; end
def sw_via(x) = x.sw(1)
p SwC.new.sw(1), SwMC.new.swm(1), SwPC.new.swp(1), SwKC.swk(1)
try_it(:super_parent) { SwB.new.sw(1) }
try_it(:super_typed) { sw_via(SwB.new) }
try_it(:super_module) { SwMB.new.swm(1) }
try_it(:super_prepend) { SwPB.new.swp(1) }
try_it(:super_class_method) { SwKB.swk(1) }
