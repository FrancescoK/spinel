# A top-level def that yields, called bare (or as self.m with a block) in a
# class's method, where a subclass defines a method of the same name: an
# instance of the subclass runs the subclass's method, with the call's block
# or with none, as CRuby looks the name up on self's class.

# a literal block, a block argument, a Symbol proc, no block
def oy1(x) = [self.class, x, yield(x)]
class OyA
  def lit = oy1(1) { |v| v.to_s * 2 }
  def arg(&b) = oy1(2, &b)
  def sym = oy1(3, &:to_s)
  def none = oy1(4)
end
class OyB < OyA; def oy1(x) = [:b, x, yield(x)]; end
[OyA.new, OyB.new].each do |o|
  p o.lit, o.arg { |v| v + 1 }, o.sym
  begin
    p o.none
  rescue LocalJumpError => e
    p [:lje, o.class, e.message]
  end
end

# block_given?, two calls in one statement, a call before the tail
def oy2(x) = block_given? ? [:top, self.class, yield(x)] : [:top, :nb]
class OyC
  def two = [oy2(1) { |v| v + 1 }, oy2(2) { |v| v.to_s }, oy2(3)]
  def mid
    r = oy2(4) { |v| v * 10 }
    [r, :tail]
  end
end
class OyD < OyC; def oy2(x) = block_given? ? [:d, yield(x)] : [:d, :nb]; end
p OyC.new.two, OyD.new.two, OyC.new.mid, OyD.new.mid

# one to three levels below, some classes without their own method, and a
# receiver whose class is known only at run time
def oy3(x) = [:top, self.class, yield(x)]
class OyE; def go(&b) = oy3(1, &b); def lit = oy3(1) { |v| v + 1 }; end
class OyF < OyE; end
class OyG < OyF; def oy3(x) = [:g, yield(x)]; end
class OyH < OyG; end
class OyI < OyH; def oy3(x) = [:i, yield(x * 2)]; end
[OyE, OyF, OyG, OyH, OyI].each { |k| p k.new.lit, k.new.go { |v| v + 1 } }
o = ARGV.empty? ? OyI.new : OyF.new
p o.lit, o.go { |v| v + 3 }

# a nil and a boxed argument, a receiver of another class beside them
def oy4(x) = [self.class, x, yield(x)]
class OyJ; def go(v) = oy4(v) { |w| w.nil? ? :nil : w.to_s }; end
class OyK < OyJ; def oy4(x) = [:k, x, yield(x)]; end
class OyZ; def go(v) = [:z, v]; end
[OyJ.new, OyK.new, OyZ.new].each { |r| p r.go(nil), r.go(5), r.go("s") }

# Object's own method in place of the top-level def
class Object; def oy5(x) = [self.class, x, yield(x)]; end
class OyL; def go = oy5(1) { |v| v + 1 }; end
class OyM < OyL; def oy5(x) = [:m, x, yield(x)]; end
p OyL.new.go, OyM.new.go

# break, next and return in the block; a block that captures and assigns
def oy6(x) = [self.class, yield(x), :after]
class OyN
  def brk = oy6(1) { |v| break [:brk, v] }
  def nxt = oy6(1) { |v| next v + 100 }
  def ret
    oy6(1) { |v| return [:ret, v] }
    :not
  end
  def cap
    acc = []
    r = oy6(2) { |v| acc << v; v * 2 }
    [r, acc]
  end
  def inblk = [1, 2].map { |i| oy6(i) { |v| v + i } }
end
class OyO < OyN; def oy6(x) = [:o, yield(x)]; end
[OyN.new, OyO.new].each { |r| p r.brk, r.nxt, r.ret, r.cap, r.inblk }

# a subclass's method that calls super, with the block and with its own
def oy7(x) = [:top, self.class, yield(x)]
class OyP; def go = oy7(1) { |v| v + 1 }; end
class OyQ < OyP; def oy7(x) = [:q, super]; end
class OyR < OyP; def oy7(x) = [:r, super(x + 1) { |v| v * 100 }]; end
p OyP.new.go, OyQ.new.go, OyR.new.go

# arms that answer different types, and one that does not yield
def oy8(x) = yield(x)
class OyS
  def str = oy8(1) { |v| v.to_s }
  def int = oy8(2) { |v| v * 2 }
end
class OyT < OyS; def oy8(x) = [:t, yield(x)]; end
class OyU < OyS; def oy8(x) = nil; end
[OyS, OyT, OyU].each { |k| r = k.new; p r.str, r.int }

# nested calls, a block that yields on, an ensure, and arms with their own
# parameter lists
def oy9(x, y = 2, k: 3)
  [self.class, x, y, k, yield(x + y)]
ensure
  puts "ensure #{x}"
end
class OyV
  def nest = oy9(1) { |v| oy9(v) { |w| w * 10 } }
  def fwd = oy9(3, k: 9) { |v| yield v }
end
class OyW < OyV; def oy9(x, *r, **kw) = [:w, x, r, kw, yield(x)]; end
[OyV.new, OyW.new].each { |r| p r.nest, r.fwd { |q| q + 100 } }

# a super chain two and three levels up into a yielding def, from a method
# called by a super below it and from one that forwards its &b
def oy10(x) = [:top, self.class, yield(x)]
class OyG3; def oy10(x) = [:x, super]; end
class OyH3 < OyG3; def oy10(x, &b) = [:y, super(x, &b)]; end
class OyI3 < OyH3; def oy10(x) = [:z, super(x) { |v| v * 7 }]; end
p OyH3.new.oy10(1) { |v| v + 1 }, OyI3.new.oy10(1) { 0 }

# a def that takes its block as &b, which a subclass overrides with a
# yielding method and with one of its own &b, called bare and by send
def oy11(x, &b) = [:top, self.class, b ? b.call(x) : :nob]
class OyA2
  def go = [oy11(1) { |v| v + 1 }, oy11(2), send(:oy11, 3) { |v| v * 2 }]
end
class OyB2 < OyA2; def oy11(x) = [:b, block_given? ? yield(x) : :nob]; end
class OyC2 < OyA2; def oy11(x, &b) = [:c, b&.call(x)]; end
[OyA2, OyB2, OyC2].each { |k| p k.new.go }

# a Method of the name, made in the superclass's method, binds the
# subclass's own method on its instance
def oy12(x = 0) = [:top, self.class, x, block_given? ? yield(x) : :nob]
class OyD2
  def go = [method(:oy12).call(1), method(:oy12).call(2) { |v| v + 1 }]
  def held = method(:oy12)
end
class OyE2 < OyD2; def oy12(x = 0) = [:e, x, block_given? ? yield(x) : :nob]; end
class OyF2 < OyE2; end
[OyD2, OyE2, OyF2].each do |k|
  m = k.new.held
  p k.new.go, [m.call(5), m.arity, m.owner]
end

# the Method made in a lambda, in a proc that escapes and in a block, where
# one arm's super reaches the def
def oy13(x) = [:top, self.class, x]
class OyA4
  def keep(&b) = b
  def inl = -> { method(:oy13) }.call.call(1)
  def esc = keep { method(:oy13).call(2) }.call
  def inb = [3].map { |v| method(:oy13).call(v) }
end
class OyB4 < OyA4; def oy13(x) = [:b, super]; end
class OyC4 < OyA4; def oy13(x) = [:c, x]; end
[OyA4, OyB4, OyC4].each { |k| o = k.new; p o.inl, o.esc, o.inb }

# a Method only asked where its method is defined
def oy14(x) = x
class OyD4; def rd = method(:oy14).source_location[1]; end
class OyE4 < OyD4; def oy14(x, y) = y; end
p OyD4.new.rd, OyE4.new.rd

# a redefined def: the Method keeps the version it was made of
def oy15(x) = [:v1, self.class, x]
class OyF4; def cap = method(:oy15); end
class OyG4 < OyF4; def oy15(x, y = 0) = [:g, x]; end
a1 = OyF4.new.cap
b1 = OyG4.new.cap
p a1.call(1), b1.call(1), a1.arity, b1.arity, a1.owner, b1.owner, a1.parameters, b1.parameters
def oy15(x, *r) = [:v2, self.class, x]
a2 = OyF4.new.cap
b2 = OyG4.new.cap
p a1.call(2), a2.call(2), b2.call(2), a2.arity, b2.arity, a2.parameters, b2.parameters

# a Symbol's to_proc as the block, with no subclass
def oy16(x) = [:top, self.class, yield(x)]
class OyH4; def go = oy16(:s, &:to_proc); end
r = OyH4.new.go
p r[0, 2], r[2].class

# the Method made in a method of an Array, String or exception subclass
def oy17(x) = [:top, self.class, x]
class OyI4 < Array; def cap = method(:oy17).call(1); def bare = oy17(2); end
class OyJ4 < OyI4; def oy17(x) = [:j, x, size]; end
class OyK4 < StandardError; def cap = method(:oy17).call(3); def bare = oy17(4); def snd = send(:oy17, 5); end
class OyL4 < OyK4; def oy17(x) = [:l, x, message]; end
class OyM4 < OyK4; end
class OyN4 < String; def cap = method(:oy17).call(6); end
p OyI4.new.cap, OyJ4.new.cap, OyI4.new.bare, OyJ4.new.bare, OyN4.new("n").cap
p OyK4.new("k").cap, OyL4.new("l").cap, OyM4.new("m").cap, OyM4.new("m").bare, OyM4.new("m").snd

# `self.method`, as the bare capture
def oy18(x) = [:top, self.class, x]
class OyO4; def cap = self.method(:oy18).call(1); end
class OyP4 < OyO4; def oy18(x) = [:p, x]; end
p OyO4.new.cap, OyP4.new.cap

# the Method unbound and bound again, on self and on another instance
def oy19(x) = [:top, self.class, x]
class OyQ4
  def b1 = method(:oy19).unbind.bind(self).call(1)
  def b4 = method(:oy19).unbind.bind(OyQ4.new).call(4)
end
class OyR4 < OyQ4; def oy19(x) = [:r, x]; end
p OyQ4.new.b1, OyR4.new.b1, OyQ4.new.b4
p((OyR4.new.b4 rescue [:err, $!.class, $!.message]))

# a subclass with its own method but no instance takes no arm: the Method's readers
def oy20(x) = [:top, self.class, x]
class OyS4
  def own = method(:oy20).owner
  def uown = method(:oy20).unbind.owner
  def line = method(:oy20).source_location[1] - __LINE__
  def ub = method(:oy20).unbind.bind(self).call(1)
  def ubo(o) = method(:oy20).unbind.bind(o).call(2)
end
class OyT4 < OyS4; def oy20(x) = [:t, x]; end
class OyU4 < StandardError; def own = method(:oy20).owner; def cl = method(:oy20).call(3); end
class OyV4 < OyU4; def oy20(x) = [:v, x]; end
o = OyS4.new
p o.own, o.uown, o.line, o.ub, o.ubo(OyS4.new), OyU4.new.own, OyU4.new.cl

# ... and one made only by allocate, dup or an anonymous subclass's new takes its arm
def oy21(x) = [:top, self.class, x]
class OyW4; def cl = method(:oy21).call(1); def own = method(:oy21).owner; def bare = oy21(2); end
class OyX4 < OyW4; def oy21(x) = [:x, x]; end
class OyY4 < OyW4; def oy21(x) = [:y, x]; end
class OyZ4 < OyW4; def oy21(x) = [:z, x]; end
[OyW4.new, OyX4.allocate, OyY4.allocate.dup, Class.new(OyZ4).new].each { |r| p [r.cl, r.own, r.bare] }

# the Method unbound and bound to self in an exception or builtin subclass's method
def oy22(x) = [:top, self.class, x]
class OyA5 < StandardError; def ub = method(:oy22).unbind.bind(self).call(1); end
class OyB5 < OyA5; def oy22(x) = [:b, x]; end
class OyC5 < OyA5; end
class OyD5 < Array; def ub = method(:oy22).unbind.bind(self).call(2); end
class OyE5 < OyD5; def oy22(x) = [:e, x]; end
class OyF5 < String; def ub = method(:oy22).unbind.bind(self).call(3); end
class OyG5 < OyF5; def oy22(x) = [:g, x]; end
p OyA5.new.ub, OyB5.new.ub, OyC5.new.ub, OyD5.new.ub, OyE5.new.ub, OyF5.new("f").ub, OyG5.new("g").ub

# the Method unbound and bound to a boxed object: an instance of the owner,
# of a subclass, of another class, nil, a scalar, a Class, an exception and builtin subclasses
def oy23(x) = [:top, self.class, x]
class OyI5; def ubo(o) = method(:oy23).unbind.bind(o).call(1); end
class OyJ5 < OyI5; def oy23(x) = [:j, x, self.class]; end
class OyK5 < OyJ5; end
class OyL5 < StandardError; end
class OyM5 < Array; end
class OyN5 < String; end
[OyJ5.new, OyK5.new, OyI5.new, nil, 4, OyJ5, OyL5.new("l"), OyM5.new, OyN5.new("n")].each do |o|
  p [(OyJ5.new.ubo(o) rescue [:err, $!.class]), OyI5.new.ubo(o)]
end
class OyO5 < StandardError; def ubo(o) = method(:oy23).unbind.bind(o).call(2); end
class OyP5 < OyO5; def oy23(x) = [:p, x, message]; end
[OyP5.new("p"), OyO5.new("o"), 5].each { |o| p((OyP5.new("q").ubo(o) rescue [:err, $!.class])) }

# bind_call of such a Method hands its arguments to whichever method it
# binds: a String, nil, an Array or a Float, on a typed and a boxed object
def oy24(s) = [:top, self.class, s]
class OyQ6
  def ubc(o, a) = method(:oy24).unbind.bind_call(o, a)
  def ubk(o, a) = method(:oy24).unbind.bind(o).call(a)
end
class OyR6 < OyQ6; def oy24(s) = [:r, s, s.class]; end
class OyS6 < OyR6; end
["s", nil, [1, 2], 2.5].each do |a|
  p [OyR6.new.ubc(OyR6.new, a), OyR6.new.ubc(OyS6.new, a), OyQ6.new.ubc(OyQ6.new, a), OyR6.new.ubk(OyR6.new, a)]
  [OyR6.new, OyS6.new, OyQ6.new, 6].each { |o| p [OyQ6.new.ubc(o, a), (OyR6.new.ubc(o, a) rescue [:err, $!.class])] }
end

# ... and of a top-level def that reads no self: the Method binds any
# object without passing it, and the subclass's arm still runs its own
def oy25(s) = [:top, s]
class OyT7
  def ubm(o) = method(:oy25).unbind.bind(o).call("m")
  def ubc(o) = method(:oy25).unbind.bind_call(o, "c")
  def ub(o) = method(:oy25).unbind.bind(o)
end
class OyU7 < OyT7; def oy25(s) = [:u, s]; end
p OyU7.new.ubm(OyU7.new), OyT7.new.ubm(OyU7.new), OyU7.new.ubc(OyU7.new), OyT7.new.ubc(OyU7.new)
[OyU7.new, OyT7.new, 7, nil, "s"].each do |o|
  p [OyT7.new.ubm(o), OyT7.new.ubc(o), OyT7.new.ub(o).call("k"), (OyU7.new.ubc(o) rescue [:err, $!.class])]
end
m = OyT7.new.ub(OyT7.new)
p m.call("one"), m.owner

# ... where the override is an included module's yielding method: the
# Method's owner, name and parameters are the module's, and it binds the
# including class's objects, typed and boxed, by bind and bind_call
def oy26(x) = yield(x)
module OyM8; def oy26(x) = [:m, yield(x), self.class]; end
class OyV8
  def mk = method(:oy26)
  def rb(o) = method(:oy26).unbind.bind(o).call(1) { |v| v + 1 }
  def rc(o) = method(:oy26).unbind.bind_call(o, 2) { |v| v * 3 }
end
class OyW8 < OyV8; include OyM8; end
class OyX8 < OyW8; end
[OyW8.new.mk, OyX8.new.mk, OyW8.new.method(:oy26), OyV8.new.mk].each do |m|
  p [m.call(5) { |v| v * 2 }, m.owner, m.name, m.arity, m.parameters]
end
p OyW8.new.method(:oy26).inspect.sub(/ \S+:\d+>/, ">")
p OyW8.new.rb(OyW8.new), OyW8.new.rb(OyX8.new), OyX8.new.rc(OyX8.new), OyV8.new.rb(OyW8.new)
[OyW8.new, OyX8.new].each { |o| p [OyW8.new.rc(o), OyX8.new.rb(o)] }

# A Method of a top-level def that reads self, made on main and unbound,
# binds to any object: kept, bound at once, or bound in a method
def oy27(a) = [self.class, a]
def oy27mk(x) = method(:oy27).unbind.bind(x)
u27 = method(:oy27).unbind
bm27 = u27.bind(5)
p bm27.call(3), u27.bind("s").call(1), u27.bind(nil).call(2), oy27mk(:y).call(4)
class OyK9; end
p u27.bind(OyK9.new).call(7), method(:oy27).unbind.bind(OyK9).call(8)

# ... followed back to the method(:m) that made it through copies and a
# local's writes, beside a def no unbind reaches, which stays main's
def oy28(a) = [self.class, a]
def oy28n = self.class
class OyK10; end
d28 = method(:oy28).dup
c28 = method(:oy28).clone
e28 = c28
f28 = method(:oy28)
f28 = f28.dup
g28 = method(:oy28)
g28 = method(:oy28) if ARGV.empty?
p d28.unbind.bind(OyK10.new).call(1)
p e28.unbind.bind(2).call(2)
p f28.unbind.bind("s").call(3)
p g28.unbind.bind(nil).call(4)
p 1.method(:succ).unbind.class, oy28n, method(:oy28n).call
