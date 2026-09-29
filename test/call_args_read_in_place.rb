# An argument that reads a variable is read where it is written, and one
# with an effect runs there, ahead of every value written after it and of
# the defaults the callee fills: CRuby evaluates a call's arguments in
# source order before it binds any. The bindings render each value, and
# each default filled at the call site, at its parameter's slot, and hoist
# the ones the slot roots ahead of the call statement, so a read left in
# place read what a later value wrote, and a value left in place ran after
# a later one or a default; an Array of reads a splat spreads was built
# after the keywords. Through a direct call, a class method, `.new` into
# `initialize`, an inlined yielding `initialize`, Method#call, a class
# method on a value of several classes, and Struct and Data members, their
# keywords out of the members' order too. A default filled at the call
# site read a variable at its parameter's slot, ahead of a later argument
# that assigns it, through the same calls, an inlined yielding method and
# super too. A parenthesized value that ran first is not run again where
# its slot boxes it.

def li(x) = (puts "li #{x}"; x)
def ls(x) = (puts "ls #{x}"; "s#{x}")
def gz(v) = (@z = 0; v)
def gs(v) = (@w = "z"; v)

def ko(p1 = 51, k1: 70) = [p1, k1]
def ks(p1, k1: "") = [p1, k1]
def kt(p1, k1: "") = [p1, k1]
def q(a, b) = [a, b]
def dk(p1, k1: ls(9)) = [p1, k1]
def dq(a, b = ls(9)) = [a, b]
def sk(a, b = 52, k1: 70, k2: 71) = [a, b, k1, k2]

# a value its slot roots, hoisted ahead of the call
u = 1; p ko(u, k1: (u = 2))
u = "a"; p ks(u, k1: (u = "b"))
u = "a"; p q(u, (u = "b"))
u = 1; p q(u, (u = 2))
@w = "a"; p q(@w, gs("c"))
@w = "a"; p ks(@w, k1: gs("c"))
p kt(li(1), k1: ls(2))
# a value built of reads, spread ahead of the keywords
u = 1; p sk(*[u, 2], k2: 4, k1: (u = 3))
# a default runs after every argument
p dk(li(1))
p dq(li(1))

class C
  def self.ks(p1, k1: 0) = [:c, p1, k1]
  def self.m(*r) = [:c, r]
  def initialize(p1 = 0, k1: 0) = (@a = [p1, k1])
  attr_reader :a
end
class E
  def self.m(*r) = [:e, r]
end
class Y
  def initialize(p1, k1: 0)
    @a = [p1, k1]
    yield self
  end
  attr_reader :a
end

@z = 1; p C.ks(@z, k1: gz(2))
@z = 1; p C.new(@z, k1: gz(2)).a
@z = 1; p Y.new(@z, k1: gz(2)) { |y| y }.a
@z = 1; p method(:ko).call(@z, k1: gz(2))
[C, E].each { |o| @z = 1; p o.m(@z, gz(2)) }

S = Struct.new(:a, :b)
DA = Data.define(:a, :b)
@w = "a"; p S.new(@w, gs("c")).to_a
@w = "a"; p DA.new(a: @w, b: gs("c")).to_h
p S.new(li(1), ls(2)).to_a
p DA.new(b: li(1), a: ls(2)).to_h
QK = Struct.new(:x, :y, keyword_init: true)
@w = "a"; p QK.new(y: gs("c"), x: @w).x

# a default filled at the call site reads what an argument bound after
# its parameter wrote
def dv(a = @y, b) = [a, b]
def gy(v) = (@y = v; v)
def dg(a = $g + 1, b, c) = [a, b, c]
def dw(k1: $g, k2:) = [k1, k2]
def dp(a, b = $g, c) = [a, b, c]
def dy(a = $g, b) = yield(a, b)
class C
  def self.dd(a = $g, b) = [:c, a, b]
end
class G
  def dd(a = $g, b) = [:g, a, b]
end
class F < G
  def dd(b) = super(($g = b; b))
end
class H
  def initialize(a = $g, b) = (@a = [a, b])
  attr_reader :a
end
@y = 0; p dv(gy(2))
$g = 0; p dg(3, ($g = 5; 5))
$g = 0; p dw(k2: ($g = 6; 6))
$g = 0; p dp(1, ($g = 7; 7))
$g = 0; p dy(($g = 8; 8)) { |a, b| [a, b] }
$g = 0; p C.dd(($g = 9; 9))
$g = 0; p method(:dp).call(1, ($g = 10; 10))
$g = 0; p F.new.dd(11)
$g = 0; p H.new(($g = 12; 12)).a

# a parenthesized value that ran first is not run again where its slot
# boxes it
u = 1; p q(u, (u = li(2)))
def km(a:, b:) = [a, b]
p km(b: (li(4)), a: 1)
p dq((li(5)))

# inside a class: a later call on self that assigns the variable
class T
  def initialize = (@h = "h0"; @n = 0)
  def seth = (@h = "h1"; 7)
  def tick = (@n += 1)
  def pm(a, b) = [a, b]
  def pd(a = @h, b) = [a, b]
  def go
    r = []
    @h = "h0"; r << pm(@h, seth)
    @h = "h0"; r << pm(@h, tick)
    @h = "h0"; r << pd(seth)
    @h = "h0"; r << S.new(@h, seth).to_a
    @h = "h0"; r << QK.new(y: seth, x: @h).x
    r
  end
end
p T.new.go
