# Enumerator::Chain.new(*enums) builds the same chain as enums[0].chain(*rest),
# and a chain answers is_a?(Enumerator::Chain), as #class already says.
a = [1, 2].each
b = [3].each
c = Enumerator::Chain.new(a, b)
p c.to_a
p c.class
p c.is_a?(Enumerator::Chain)
p c.is_a?(Enumerator)
p (a + b).is_a?(Enumerator::Chain)
p [1, 2].chain([3]).is_a?(Enumerator::Chain)
p [1].each.is_a?(Enumerator::Chain)
enums = [[1].each, [2, 3].each]
d = Enumerator::Chain.new(*enums)
p d.to_a
p d.select { |x| x > 1 }
p Enumerator::Chain.new.to_a
p Enumerator::Chain.new([1, 2], 3..4).to_a
p Enumerator::Chain.new(*[[5].each]).map { |x| x * 2 }
# a boxed value asked about the class, as a serializer walking any object does
[[1].each + [2].each, [1].each, Enumerator::Product.new([1], [2]), 5, "s", nil].each do |v|
  p [v.is_a?(Enumerator::Chain), v.is_a?(Enumerator::Product), v.is_a?(Enumerator), v.is_a?(Enumerator::Lazy)]
end
# a source that cannot be enumerated raises CRuby's NoMethodError (CRuby when the
# chain is iterated, spinel's snapshot chain when it is built)
[5, nil, "s"].each do |bad|
  begin
    Enumerator::Chain.new([1].each, bad).to_a
  rescue NoMethodError => e
    puts e.message
  end
end
