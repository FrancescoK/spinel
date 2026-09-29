def g(o)
  r = o.uniq { |x| x % 2 }
  p r
  r
end
p g(Enumerator.new { |y| y << 1; y << 2; y << 3 })
p g([1, 2, 3])
p g(1..3)
p g([1.0, 2.0, 3.0])
def h(o) = o.uniq
p h([1, 1, 2])
p h(Enumerator.new { |y| y << 1; y << 1 })
def k(o)
  r = o.uniq! { |x| x % 2 }
  [r, o]
end
p k([1, 2, 3])
p k([1, 2])
p k([1.0, 2.0, 3.0])
p k([1, "a", 3].map { |x| x.is_a?(String) ? 0 : x })
def m(o) = o.uniq { |a, b| b }
p m({a: 1, b: 1, c: 2})
p m([1, 2])
p m(Enumerator.new { |y| y.yield 1, 2; y.yield 3, 2; y.yield 4, 5 })
def z(o) = o.uniq { |x| x }
p z(Enumerator.new { |y| y.yield 1, 2; y.yield 1, 2 })
p z([1, 2])
begin
  z(5)
rescue NoMethodError => e
  puts e.message
end
begin
  k([1, 2].freeze)
rescue => e
  puts e.class
end
