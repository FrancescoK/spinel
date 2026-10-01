# A blockless each_with_index on a Struct that defines its own
# each_with_index calls that method.
R = Struct.new(:a, :b) do
  def each_with_index
    return :custom unless block_given?
    yield :x, 0
    self
  end
end
r = R.new(1, 2)
p r.each_with_index
r.each_with_index { |v, i| p [v, i] }

P = Struct.new(:a, :b)
p P.new(3, 4).each_with_index.to_a
