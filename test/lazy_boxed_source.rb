def f(o) = o.lazy.map { |x| x * 2 }.first(2)
p f([1, 2, 3])
p f(1..3)
p f(1..)
p f(Enumerator.new { |y| i = 0; loop { y << (i += 1) } })
def g(o)
  p o.lazy.select { |x| x.odd? }.map { |x| x * 10 }.first(2)
  p o.lazy.map { |x| x + 1 }.to_a
  p o.lazy.first(2)
  p o.lazy.first
  p o.lazy.reject { |x| x == 2 }.force
  p o.lazy.take(2).to_a
  p o.lazy.with_index.map { |x, i| x * i }.first(3)
  l = o.lazy.map { |x| x - 1 }
  p l.first(2)
end
g([1, 2, 3])
g(1..3)
g([4, 5, 6].each)
def h(o) = o.lazy.map { |k, v| v }.first(1)
p h({ a: 1, b: 2 })
begin
  f(5)
rescue NoMethodError => e
  puts e.message
end

# a boxed value with no each raises, as lazy does in CRuby
class LazyBox; end
class LazyCol
  include Enumerable
  def each = [7, 8].each { |x| yield x }
end
def lazy_two(o) = o.lazy.map { |x| x * 2 }.first(2)
[5, LazyBox.new, LazyCol.new, [1, 2]].each do |v|
  begin
    p lazy_two(v)
  rescue NoMethodError => e
    p e.class
  end
end
