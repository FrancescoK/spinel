# `self.class.new(*a)` in a Struct's method spreads the array across the
# members, as `S.new(*a)` does
S = Struct.new(:a, :b) do
  def merge(o) = self.class.new(*members.map { |m| o[m] || self[m] })
  def swap = self.class.new(*to_a.reverse)
  def short = self.class.new(*[a])
end
p S.new(1, nil).merge(S.new(nil, 2)).to_a
p S.new(1, 2).swap.to_a, S.new(5, 6).short.to_a
K = Struct.new(:x, :y, keyword_init: true) do
  def again = self.class.new(**to_h)
end
p K.new(x: 1, y: 2).again.to_h
