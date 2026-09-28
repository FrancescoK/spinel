# A keyword written twice into a method or a block binds its last value, as
# CRuby does, and every value is evaluated once, in source order. The first
# value bound and the second never ran: through a direct call, the virtual
# dispatch, an inlined yielding method or initialize, a class method, `send`,
# `super`, a poly receiver, Method#call and a yield into a block's keyword
# params. A `**kw` rest beside the named params takes the last value of a key
# none names, and the repeat merges with a `**` in source order. The last
# value's class is the parameter's. Keywords written out of the parameters'
# order run in source order too, nil values included (they ran in parameter
# order), and a call refused for a missing or unknown keyword or its count
# raises only once its arguments have run (it raised first). A hash of Symbol
# keys alone keeps a repeated key once, where it is last written, as CRuby
# compiles it; beside a `**` or another kind of key it keeps its first place.
def lit(v) = (puts "lit #{v}"; v)

def try
  p yield
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end

def k(a:, b: 0) = [a, b]
def kr(a:, b:) = [a, b]
def mix(a: 0, **kw) = [a, kw]
def rest(**kw) = kw
def dflt(a: 1, b: a) = [a, b]
def ky(a:, b: 0) = yield(a, b)
def pos(x, a: 0) = [x, a]

class B
  def initialize(a: 0, b: 0)
    @a = a
    @b = b
  end

  def pair = [@a, @b]
  def k(a:, b: 0) = [a, b]
  def self.k(a:, b: 0) = [a, b]
  def self.build = new(a: lit(1), a: lit(2))
end

class E < B
  def k(a:, b: 0) = super(a: lit(a), b: b, a: lit(a + 1))
end

class Y
  def initialize(a:, b: 0)
    @v = yield(a, b)
  end

  attr_reader :v
end

try { k(a: lit(1), a: lit(2)) }
try { k(b: lit(1), a: lit(2), b: lit(3)) }
try { k(a: "s", a: 2) }
try { k(a: puts("replaced"), a: 2) }
try { kr(b: lit(1), a: lit(2), a: lit(3)) }
try { mix(a: lit(1), z: lit(2), a: lit(3), z: lit(4)) }
try { rest(z: lit(1), z: lit(2)) }
try { dflt(a: lit(5), a: lit(6)) }
try { pos(lit(0), a: lit(1), a: lit(2)) }
try { ky(a: lit(1), a: lit(2)) { |a, b| [a, b] } }
try { B.new(b: lit(1), b: lit(2)).pair }
try { B.build.pair }
try { B.new.k(a: lit(1), a: lit(2)) }
try { B.k(a: lit(1), a: lit(2)) }
try { E.new.k(a: 5) }
try { B.new.send(:k, a: lit(1), a: lit(2)) }
try { B.send(:k, a: lit(1), a: lit(2)) }
try { Y.new(a: lit(1), a: lit(2)) { |a, b| [a, b] }.v }

# the virtual dispatch and a poly receiver
[B.new, E.new].each { |o| try { o.k(a: lit(1), a: lit(2)) } }
[B.new, "s"].each { |o| try { o.k(a: lit(1), a: lit(2)) } if o.is_a?(B) }
[B, E].each { |c| try { c.k(a: lit(1), a: lit(2)) } }

# Method#call
m = B.new.method(:k)
try { m.call(a: lit(1), a: lit(2)) }
try { m.call(b: lit(1), a: lit(2), b: lit(3)) }
try { m.call(a: puts("replaced"), a: 2) }
try { method(:k).call(a: lit(1), a: lit(2)) }

# beside a `**`, ahead of it or after it
h = { b: 9 }
g = { a: 7 }
try { k(a: lit(1), **h, a: lit(2)) }
try { k(a: lit(1), a: lit(2), **h) }
try { k(**h, a: lit(1), a: lit(2)) }
try { k(a: lit(1), a: lit(2), **g) }
try { mix(a: lit(1), a: lit(2), **h, z: lit(3), z: lit(4)) }
try { rest(z: lit(1), **h, z: lit(2)) }
try { B.new.k(a: lit(1), **g, a: lit(2)) }

# out of the parameters' order, nil values included
def k2(a:, b:) = [a, b]
try { k2(b: lit(1), a: lit(2)) }
try { k(b: puts("nil b"), a: lit(1)) }
try { B.new.k(b: puts("nil b"), a: lit(2)) }
try { B.k(b: lit(1), a: lit(3)) }
try { mix(z: lit(1), a: lit(2)) }
try { method(:k2).call(b: lit(3), a: lit(4)) }
try { m.call(b: puts("nil b"), a: lit(5)) }
try { Y.new(b: lit(1), a: lit(6)) { |a, b| [a, b] }.v }
try { Y.new(b: puts("nil b"), a: lit(7)) { |a, b| [a, b] }.v }
try { ky(b: lit(1), a: lit(8)) { |a, b| [a, b] } }

# a block's keyword params
def yk = yield(a: lit(1), a: lit(2))
def yo = yield(lit(0), b: lit(1), a: lit(2), b: lit(3))
def yr = yield(a: lit(1), z: lit(2), a: lit(3))
def ys = yield(a: "s", a: 2)
def yn = yield(b: puts("nil b"), a: lit(4))
def yc(&b) = b.call(a: lit(1), a: lit(2))
try { yk { |a:| a } }
try { yo { |x, a:, b: 9| [x, a, b] } }
try { yr { |a:, **kw| [a, kw] } }
try { ys { |a:| a } }
try { yn { |a:, b: 0| [a, b] } }
try { yc { |a:| a } }
try { proc { |a:| a }.call(a: lit(1), a: lit(2)) }
try { ->(a:, b: 0) { [a, b] }.(b: lit(1), a: lit(2), b: lit(3)) }

# refused only once every argument has run
def one(x) = x
try { k(z: lit(1)) }
try { kr(b: lit(2)) }
try { k(a: lit(3), z: lit(4), a: lit(5)) }
try { B.new.k(z: lit(6)) }
try { B.k(z: lit(7)) }
try { B.new.send(:k, z: lit(8)) }
try { ky(z: lit(9)) { |a, b| [a, b] } }
try { B.new(z: lit(10)) }
try { one(lit(11), lit(12)) }
try { k(lit(13), a: lit(14)) }

# into a method without keyword params, and the hash's key order
def g(a, h = nil) = [a, h]
def pr(*r, z) = [r, z]
def req(a, h) = [a, h]
class B
  def g(a, h = nil) = [a, h]
  def r(**kw) = kw
end
class E
  def r(**kw) = [kw]
end
try { g(1, a: lit(1), a: lit(2)) }
try { pr(1, a: lit(1), a: lit(2)) }
try { req(0, b: lit(1), a: lit(2), b: lit(3)) }
try { B.new.g(1, a: lit(1), a: lit(2)) }
try { method(:g).call(1, a: lit(1), a: lit(2)) }
try { g(1, a: lit(1), **h, a: lit(2)) }
try { rest(b: lit(1), a: lit(2), b: lit(3)) }
try { rest(b: 1, a: 2, b: 3, **h) }
try { g(1, b: 1, "a" => 2, b: 3) }
try { mix(b: lit(1), z: lit(2), b: lit(3)) }
[B.new, E.new].each { |o| try { o.r(b: lit(1), a: lit(2), b: lit(3)) } }
def yr = yield(z: lit(1), q: lit(2), z: lit(3))
try { yr { |**kw| kw } }
try { { b: 1, a: 2, b: 3 } }
