# Array#product's operand is an Array, converted as CRuby converts it: a
# boxed operand (a local holding an Array or a String, an element read) is
# taken as the Array it holds at run time, and anything else, nil included,
# raises the implicit-conversion TypeError. A boxed operand did not build,
# and a nil general Array read as empty.

def t
  yield
rescue => e
  puts "#{e.class}: #{e.message}"
end
a = [1, nil]
q = ARGV[0] || a
p [1].product(q)
p [1, 2].product(q, q)
[1].product(q) { |pr| p pr }
r = ARGV.empty? ? "s" : a
t { p [1].product(r) }
t { [1].product(r) { |pr| p pr } }
n = ARGV.empty? ? nil : a
t { p [1].product(n) }
p [1.5].product(q), ["x"].product(q)
p [1].product([1, q[0]])
