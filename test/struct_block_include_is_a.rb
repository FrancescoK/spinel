# is_a?, kind_of? and a `when` on a boxed instance of a class whose module
# comes from a Struct.new or Data.define block, named or made in an
# expression: the class tests read the load record's includes
module M; def hi = "m"; end
S = Struct.new(:a) { include M }
x = [S.new(1), 1][0]
p x.is_a?(M)
case x
when M then p :m
else p :no
end
ks = [Struct.new(:a) { include M }]
o = ks[0].new(1)
p o.is_a?(M), o.kind_of?(M), M === o, o.hi
D = Data.define(:v) { include Comparable; def <=>(other) = v <=> other.v }
d = [D.new(1), 2][0]
p d.is_a?(Comparable)
