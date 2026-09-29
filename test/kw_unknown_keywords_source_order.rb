# The unknown keywords of a call with a `**` are named in the order of the
# hash CRuby makes of them: the literal keys written ahead of the `**`, the
# keys it brings, then the literal keys written after it, save one the `**`
# holds, which keeps the `**`'s place. Every literal key no keyword takes was
# named ahead of the `**`'s: `m(**{z: 2}, "s" => 1)` answered `unknown
# keywords: "s", :z` where CRuby answers `:z, "s"`. Through a direct call,
# a class method, an inlined yielding method, `super`, class values, `.new`,
# Method#call and `send`; the virtual dispatch, a proc and a yield into a
# block's keyword params named them in order already.
def try
  p yield
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end
h = { z: 2 }
g = { "t" => 1, y: 0 }
class A
  def self.c(k1: 70) = [k1]
  def d(k1: 70) = [:a, k1]
  def y(k1: 70) = yield(k1)
  def s(k1: 70) = [:s, k1]
end
class B < A
  def d(k1: 70) = [:b, k1]
  def s(k1: 70) = super(**{ z: 2 }, y: 3)
end
class Q; def self.cm(k1: 70) = [:q, k1]; end
class R; def self.cm(k1: 70) = [:r, k1]; end
class P; def initialize(k1: 70) = (@k1 = k1); end
def m1(k1: 70) = [k1]
def m2(k1:, k2: 0) = [k1]
try { A.c(**h, "s" => 1) }
[A.new, B.new].each { |o| try { o.d(**h, "s" => 1) } }
try { A.new.y(**h, y: 3) { |v| v } }
try { B.new.s }
[Q, R].each { |o| try { o.cm(**h, y: 3) } }
try { P.new(**h, y: 3) }
try { method(:m1).call(**h, y: 3) }
try { send(:m1, **h, "s" => 1) }
try { m1(**g, "s" => 1, y: 4, x: 5) }
try { m1(x: 1, **g, "s" => 1, "t" => 4) }
try { m2(**h, k1: 1, y: 3) }
try { m2(**h, y: 3) }
pr = proc { |k1: 70| k1 }
try { pr.call(**h, y: 3) }
def yy(h) = yield(**h, y: 3)
try { yy(h) { |k1: 70| k1 } }
try { m1(**h, "s" => 1) }
try { m1("s" => 1, **h) }
try { m1(**h, "s" => 1, y: 3) }
try { m1(y: 3, **h, "s" => 1) }
yh = { y: 1 }
sh = { "s" => 1 }
try { m1(**yh, y: 3) }
try { m1(**sh, "s" => 2, "u" => 3) }
