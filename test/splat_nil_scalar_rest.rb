# A nil splatted into a rest parameter spreads to nothing, as `*nil` does,
# when the nil rides in an Integer or Float slot (the sentinel a missed read
# leaves, or a literal nil) or in a String slot; any other scalar is one
# element.

def sc(*a) = a
def sc2(a, *r) = [a, r]
def kw(*a, k: 1) = [a, k]
class C
  def self.cm(*a) = a
  def im(*a) = a
end
class D < C
  def im(*a) = super(*a, *z)
  def z = [5][ARGV.size + 1]
end

x = 1
p sc(*x)
x = nil
p [sc(*x), sc(0, *x), sc(*x, 2), sc2(0, *x), kw(*x), kw(*x, k: 2)]
f = [1.5][ARGV.size + 1]
g = [2.5][ARGV.size]
p [sc(*f), sc(0, *f), sc(*g)]
s = "a"
s = nil if ARGV.empty?
p [sc(*s), sc(0, *s), sc(*"b")]
p [C.cm(*x), C.new.im(*f), D.new.im(1)]
