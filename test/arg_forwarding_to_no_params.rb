# A method forwarding `...` to one that takes no argument passes on what it
# is given, and the target refuses any of it with CRuby's wrong count. The
# forward bound the arguments into synthesized slots it handed nowhere, so
# `w(1)` and `w(*[], **{"s" => 1})` into `def m()` answered `[]`; a splat
# into it failed to build. Through a top-level method, one with a leading
# parameter, a chain of forwarders, instance and class methods, `new(...)`
# into an initialize taking nothing and `super(...)` into one, and with a
# block; the forwarder's own statements run first, as in CRuby.
def try
  p yield
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end
h = { "s" => 1 }
e = []
def m0() = [:m0]
def w0(...) = (puts "w0"; m0(...))
try { w0(*[], **h) }
try { w0 }
def m1() = [:m1]
def w1(a, ...) = [a, m1(...)]
try { w1(1, 2) }
try { w1(1) }
def m2() = [:m2]
def w2(...) = m2(...)
def v2(...) = w2(...)
try { v2(*e, 1) }
try { v2 }
class C
  def m = [:c]
  def w(...) = m(...)
  def self.cm = [:cm]
  def self.cw(...) = cm(...)
end
try { C.new.w(**h) }
try { C.new.w }
try { C.cw(1) }
try { C.cw }
class P
  def initialize = (@p = 1)
  attr_reader :p
  def self.make(...) = new(...)
end
try { P.make(1) }
try { P.make.p }
class Q < P
  def initialize(...) = super(...)
end
try { Q.new(*e, **h) }
try { Q.new.p }
def m3() = [:m3]
def w3(...) = m3(...)
try { w3(1) { 2 } }
try { w3 { 2 } }
