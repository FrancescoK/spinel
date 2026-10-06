# clamp and between? on a boxed receiver: a value that is no Comparable
# (nil, an Array, a Hash, a Range) raises NoMethodError with the bounds as
# its args, where the comparison raised ArgumentError, and a String or a
# Symbol with a bound it cannot compare raises the comparison's
# ArgumentError, where Comparable's own helper was looked up on it. Both
# hold beside an Integer literal receiver, which takes builtins/
# comparable.rb's definitions.

def t
  p yield
rescue NoMethodError => e
  puts "#{e.message} #{e.args.inspect}"
rescue => e
  puts "#{e.class}: #{e.message}"
end

k = ARGV.size
[nil, :sy, "s", [1, 2], {a: 1}, 1..2, 2.5, 3, "b"].each do |v|
  n = [v, 0][k]
  t { n.clamp(1, 2) }
  t { n.between?(1, 2) }
  t { n.clamp(1..2) }
  t { n.clamp("a", "c") }
end
t { 3.clamp(1, 2) }
t { 3.between?(1, 5) }
# a concrete Integer or Float slot holding nil
x = nil
x = 5 if k > 0
t { x.clamp(1, 2) }
t { x.between?(1, 2) }
f = nil
f = 2.5 if k > 0
t { f.clamp(1.0, 2.0) }
