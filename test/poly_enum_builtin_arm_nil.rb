# A builtin Enumerable arm beside a user method of the same name serves
# Arrays, Hashes and Ranges; nil, an Integer or an unrelated object still
# raises NoMethodError naming the method (nil must not run the block zero
# times as if it were []).
class Grid
  def each_cons(n)
    yield [:grid, n]
    :g
  end
end
class Other; end

def stmt(v)
  acc = []
  v.each_cons(2) { |a| acc << a }
  p acc
rescue NoMethodError => e
  p e.message
end

def value(v)
  acc = []
  r = v.each_cons(2) { |a| acc << a }
  p [r.class, acc]
rescue NoMethodError => e
  p e.message
end

[Grid.new, [1, 2, 3], 1..4, { a: 1, b: 2 }, Other.new, nil, 5, "str"].each do |v|
  stmt(v)
  value(v)
end
