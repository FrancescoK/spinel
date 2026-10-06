# sum, count and first on a boxed value that is no collection raise CRuby's
# NoMethodError: a Symbol summed to 0 and counted its length, and a user
# object with no #each summed to 0, counted 0 and answered nil for first.
# A Struct and a class including Enumerable answer through their members.

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

vals = [[3, 1, 2], { a: 1 }, 1..3, Pt.new(5, 6), Bag.new, [4, 5].each,
        :sym, Nope.new, nil, 5]
vals.each do |v|
  puts "-- #{v.class}"
  t("sum") { v.is_a?(Hash) ? :skip : v.sum }
  t("count") { v.count }
  t("first") { v.first }
end
