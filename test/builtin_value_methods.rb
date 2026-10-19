# Object#methods and #public_methods on builtin values answer the names
# CRuby lists for the value's class: nil, true and false, an Integer, a
# Float, a Symbol, a String, an Array, a Hash, a Range, a Regexp, a
# Rational, a Proc and a bare Object, typed or boxed. They raised
# NoMethodError, where only an instance of the program's own class listed.

p nil.methods.size, true.methods.size, false.methods.size
p 1.methods.size, 1.5.methods.size, :a.methods.size, "s".methods.size
p [1].methods.size, { a: 1 }.methods.size, (1..2).methods.size, (1.0..2.0).methods.size
p /a/.methods.size, 1r.methods.size, proc {}.methods.size
p 1.public_methods.size, "s".methods(true).size
p 1.methods.include?(:+), "s".methods.include?(:upcase), nil.methods.include?(:upcase)
p (nil.methods - Object.new.methods).sort
p (true.methods - Object.new.methods).sort
p nil.methods.uniq.size == nil.methods.size

# a receiver that may hold nil lists as the value it holds
s = "abc" if ARGV.size > 5
p s.methods.size

# a boxed receiver, by its class at run time
class Point
  def x = 1
end
[nil, true, 7, 2.5, :k, "str", [1], { b: 2 }, (3..4), /re/, 3r, Object.new, Point.new].each do |v|
  p [v.class, v.methods.size, v.public_methods.size]
end
n = 1
n += 1
p n.methods.size

