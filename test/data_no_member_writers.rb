# A Data class has readers but no writers: `x=` is not answered by
# respond_to?, not defined, and calling it raises NoMethodError. A Struct keeps
# its writers.

D = Data.define(:x, :y)
S = Struct.new(:x, :y)
d = D.new(x: 1, y: 2)
s = S.new(1, 2)
p [d.respond_to?(:x=), d.respond_to?(:y=), d.respond_to?(:x), d.respond_to?(:z), d.respond_to?(:z=)]
p [d.respond_to?("x="), d.respond_to?(:with), d.respond_to?(:to_h), d.respond_to?(:[]), d.respond_to?(:[]=)]
p [s.respond_to?(:x=), s.respond_to?(:y=), s.respond_to?(:x), s.respond_to?(:z), s.respond_to?(:z=)]
p [s.respond_to?("x="), s.respond_to?(:with), s.respond_to?(:to_h), s.respond_to?(:[]), s.respond_to?(:[]=)]
p [D.method_defined?(:x=), S.method_defined?(:x=), D.method_defined?(:x)]
begin
  d.x = 2
rescue NoMethodError => e
  p e.class
end
p d.x
s.x = 5
p s.x

syms = %i[a b]
E = Data.define(*syms)
e = E.new(a: 1, b: 2)
p [e.respond_to?(:a=), e.respond_to?(:a)]
