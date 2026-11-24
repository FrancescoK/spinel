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
