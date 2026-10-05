# `to_enum(:m)` in a reopened Array's method m answers an Enumerator over
# m, as in a program class: activesupport's Array#extract! returns
# `to_enum(:extract!) { size }` without a block. It raised NoMethodError
# for to_enum on an Array, and where its generator was built, the fiber
# captured self as a struct the reopening does not have, and the C did
# not compile.
class Array
  def extract!
    return to_enum(:extract!) unless block_given?
    extracted_elements = []
    reject! do |element|
      extracted_elements << element if yield(element)
    end
    extracted_elements
  end
  def each_odd
    return to_enum(:each_odd) unless block_given?
    each { |x| yield x if x.odd? }
    self
  end
end
a = [1, 2, 3, 4]
p a.extract!(&:odd?)
p a
p [5, 6, 7].extract!.class
p [1, 2, 3, 4, 5].each_odd.to_a
