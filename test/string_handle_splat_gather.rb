# A String a method appends to through a splat or a gather is the caller's
# String (#6179): the Array the call builds holds the shared handle, so the
# append made through the parameter the Array fills (or through the rest's
# element) reaches the caller, in a direct call, a class value's and a poly
# receiver's dispatch. Each append is 100 bytes, so a copy cannot pass by
# capacity; a method that only reads keeps its String a plain one.
# spinel: gc-minor
X = "x" * 100
def m1(p) = (p << X; nil)
def m2(a, p) = (p << X; nil)
def g1(*r) = (r[0] << X; nil)
def g2(a, *r) = (r[-1] << X; nil)
def g3(*r) = (r.each { |x| x << X }; nil)
def rd(*r) = r[0].size
class C
  def m(p) = (p << X; nil)
  def self.cm(p) = (p << X; nil)
end
class Ini; def initialize(p) = (p << X); end
class Box; def initialize(a, b) = (b << X; nil); end
class A; def w(p) = (p << X; nil); end
class B; def w(p) = (p.size; nil); end
e = []

v = +"a"; m1(*e, v); p v.size                        # a runtime splat ahead of it
v = +"a"; s = [v]; m1(*s); p v.size                  # a local Array holding it, splatted
v = +"a"; s = [v]; C.new.m(*s); p v.size, s[0].size  # into a lent parameter
v = +"a"; m2(*[1], v); m2(*e, 1, v); p v.size       # a literal and a runtime splat
v = +"a"; g1(v); p v.size                            # a gather
v = +"a"; w = +"b"; g2(1, v, w); g3(v, w); p v.size, w.size
v = +"a"; k = [C, C][ARGV.size]; k.cm(*e, v); k.new.m(*e, v); p v.size   # a class value
v = +"a"; [A.new, B.new].each { |o| s = [v]; o.w(*s); o.w(*e, v) }; p v.size   # poly dispatch
v = +"a"; s = [v]; Ini.new(*s); p v.size            # new, into initialize
v = +"a"; Box.new(*[1, v]); p v.size                 # a literal holding the String
v = +"a"; Box.new(*[v, v]); p v.size                 # one holding only Strings
v = +"a"; p rd(v), v.size                            # a reader
wa = +"b"; sa = [+"a"]; sa << wa; Box.new(*sa); p wa.size   # an Array changed after its literal
f2 = ->(x, y) { y << X }
wb = +"b"; sb = [+"a"]; sb << wb; f2.call(*sb); p wb.size
sc = [+"a"]; sc.clear; sc << +"z"; C.new.send(:m, *sc); p sc[0].size
fz = "fr".freeze; begin; m1(*e, fz); rescue FrozenError => ex; p ex.class; end
v = +"a\0b"; g1(v); p v.size, v.bytes.first(4)
