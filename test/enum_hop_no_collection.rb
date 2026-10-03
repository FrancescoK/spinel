# The Enumerable calls a boxed receiver serves through its members (each_cons,
# each_slice, each_with_index, each_entry and reverse_each without a block,
# and the counted take / first / drop / last / min / max) raise CRuby's
# NoMethodError, naming the method called, for a value that is no
# collection. nil (which has #to_a) answered [], a String or a user object
# with no #each answered [] too, and an Integer or a Symbol named to_a.
# A collection of any kind still answers.

def t(s)
  r = yield
  puts "#{s}: #{r.inspect}"
rescue NoMethodError => e
  puts "#{s}: #{e.message}"
end

class Nope; end
class Bag
  include Enumerable
  def each
    yield 3
    yield 1
    yield 2
  end
end
Pt = Struct.new(:x, :y)

vals = [[3, 1, 2], { a: 1, b: 2 }, 1..3, Pt.new(5, 6), Bag.new, [4, 5].each,
        nil, 5, :sym, "str", Nope.new]
vals.each do |v|
  puts "-- #{v.class}"
  t("each_cons") { v.each_cons(2).to_a }
  t("each_slice") { v.each_slice(2).to_a }
  t("each_with_index") { v.each_with_index.to_a }
  t("each_entry") { v.each_entry.to_a }
  t("reverse_each") { v.reverse_each.to_a }
  t("take") { v.take(1) }
  t("first") { v.first(1) }
  t("drop") { v.drop(1) }
  t("min") { v.min(1) }
  t("max") { v.max(1) }
end
