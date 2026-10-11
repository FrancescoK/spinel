# An op-assign on an Integer-keyed Hash whose key may be nil or of another
# class at run time (a boxed key through a parameter) looks it up as CRuby
# does: such a key misses. `&&=` then stores nothing, and `op=` raises for
# the nil it read; an Integer key reads and stores as before.
def and_e(h, k) = (h[k] &&= 3)
def add_e(h, k) = (h[k] += 1)
def or_e(h, k) = (h[k] ||= 9)
def and_s(h, k); h[k] &&= 3; :ok; end
def add_s(h, k); h[k] += 1; :ok; end
def t
  p yield
rescue NoMethodError => e
  puts "NoMethodError: #{e.message}"
end
[nil, "x", 2].each do |k|
  h = { 1 => 5 }
  t { and_e(h, k) }
  t { and_s(h, k) }
  t { add_e(h, k) }
  t { add_s(h, k) }
  p h
end
[1, 2].each do |k|
  h = { 1 => 5 }
  t { and_e(h, k) }
  t { add_e(h, k) }
  t { or_e(h, k) }
  t { add_s(h, k) }
  p h
end
s = { 1 => "a" }
def str_and(h, k) = (h[k] &&= "z")
p str_and(s, nil)
p str_and(s, "x")
p str_and(s, 1)
p s
