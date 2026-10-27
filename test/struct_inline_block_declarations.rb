# the block of a Struct.new or Data.define that no constant holds, in an
# expression or in a method body, is its class's body for every class-body
# declaration: an include, an attr, a visibility word
module InlHi; def hi = "hi #{x}"; end
o = Struct.new(:x) { include InlHi; attr_accessor :y }.new(1)
o.y = 5
p o.hi, o.y
def inl_make = Struct.new(:a) { include InlHi; def x = a * 2 }
p inl_make.new(4).hi
d = Data.define(:x) { include InlHi; private def secret = 1 }.new(x: 3)
p d.hi
begin
  d.secret
rescue NoMethodError => e
  p e.class
end
