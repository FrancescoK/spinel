# Reflection on Struct and Data classes lists what CRuby lists: the member
# accessors and the methods the class body defines, never the iterators
# spinel generates for a struct or the __to_enum_* / __enum_to_a helpers.
# Object#methods, #public_methods and #singleton_methods answer an Array of
# Symbols for a user object.

module Greet
  def greet; "hi"; end
end

S = Struct.new(:x, :y)
D = Data.define(:x, :y)
S2 = Struct.new(:a) do
  def hi; 1; end
end
D2 = Data.define(:a) do
  def hi; 1; end
end
class T < Struct.new(:a)
  def t; end
end
class E < Data.define(:a)
  def e; end
end
class Bare; end
class P
  include Greet
  def q; end
  alias q2 q
  protected def r; end
  private def s; end
  attr_reader :z
  def each
    yield 1
    yield 2
  end
end
class Q < P
  include Comparable
  def <=>(o); 0; end
  def w; end
end

p S.instance_methods(false).sort
p D.instance_methods(false).sort
p S2.instance_methods(false).sort
p D2.instance_methods(false).sort
p T.instance_methods(false).sort
p E.instance_methods(false).sort
p P.instance_methods(false).sort
p Q.instance_methods(false).sort
p S.public_instance_methods(false).sort
p P.private_instance_methods(false).sort

p S.method_defined?(:__to_enum_each)
p S.method_defined?(:each), S.method_defined?(:each, false), S.method_defined?(:each_with_index, false)
p D.method_defined?(:each), D.method_defined?(:each_pair), D.method_defined?(:x)
p T.method_defined?(:a, false), T.method_defined?(:a), T.method_defined?(:t, false)
p P.method_defined?(:greet), P.method_defined?(:greet, false)

s = S.new(1, 2)
d = D.new(x: 1, y: 2)
p s.respond_to?(:__to_enum_each), s.respond_to?(:each), s.respond_to?(:map)
p d.respond_to?(:each), d.respond_to?(:map), d.respond_to?(:with)
p E.new(a: 1).respond_to?(:each)

p s.methods.include?(:x=)
p d.methods.include?(:x), d.methods.include?(:each)
p s.public_methods.include?(:each_pair)
p s.methods.include?(:__to_enum_each)
p (s.methods - Bare.new.methods).sort
p (d.methods - Bare.new.methods).sort
p (T.new(1).methods - Bare.new.methods).sort
p (E.new(a: 1).methods - Bare.new.methods).sort
p (Q.new.methods - Bare.new.methods).sort
p (Q.new.public_methods - Bare.new.public_methods).sort
p Bare.new.methods.sort
p s.singleton_methods, d.singleton_methods

o = P.new
def o.k; end
p o.singleton_methods, o.methods.include?(:k)
p o.to_enum(:each).to_a
p S2.new(1).first
