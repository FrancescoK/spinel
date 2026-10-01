p Enumerator::Product.new([1, 2], [:a, :b]).to_a
p Enumerator.product([1, 2], [:a, :b]).to_a
p Enumerator.product.to_a, Enumerator.product([1, 2]).map { |a| a }
p Enumerator.product(1..2, ["A", "B"]).to_a
p Enumerator.product(1..2, ["A"], ["B"], ["C"]).to_a
e = Enumerator::Product.new([1, 2], [:a])
p e.class, e.inspect, e.size
p Enumerator.product(1..2, 1..3, 1..4).size
r = Enumerator.product([1, 2], [3]) { |x| p x }
p r
p Enumerator.product([1], [2]).map { |a, b| a + b }
p Enumerator.product("ab".each_char, [1]).to_a
p Enumerator.product(1..2, { a: 1 }).to_a
a = [1, 2, 3]
i = 0
en = Enumerator.new do |y|
  while i < a.size
    y << a[i]
    i += 1
  end
end
p Enumerator.product(['a', 'b'], en).to_a
p((Enumerator.product(1..3, foo: 1, bar: 2) rescue $!.message))
p((Enumerator.product(1..3, foo: 1) rescue $!.message))
kw = { "s" => 1, b: 2 }
p((Enumerator.product([1], **kw) rescue $!.message))
p Enumerator.product([1], **{}).to_a
x = [Enumerator.product([1], [2]), 1][0]
p x.class
p Enumerator.product(*[[1, 2], [3]]).to_a
p [[1].chain([2]), 1][0].class
