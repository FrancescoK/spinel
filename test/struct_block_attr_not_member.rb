# The same for attrs and ivars declared in the Struct.new/Data.define block.
S = Struct.new(:a, :b) do
  attr_accessor :z
  attr_reader :y
  def bump; @y = (@y || 0) + 1; end
end
s = S.new(1, 2)
p S.members
p s
s.z = 3
s.bump
p s.z, s.y
p s.to_a, s.to_h
p s == S.new(1, 2)
p S.new(1)
D = Data.define(:x) do
  attr_reader :memo
end
d = D.new(x: 4)
p d, D.members, d.memo, d.to_h
p d.with(x: 5)
p D.new(4)
v = [S.new(5, 6), 1].first
p v
p v.to_a
