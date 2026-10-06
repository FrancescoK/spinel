# count(x), sum(init) and sum with a block on a boxed receiver that has
# no such methods (nil, an Integer, a Float, true, a Symbol) raise
# NoMethodError, with the arguments as its args. They answered 0, or the
# initial value. Collections still count and sum, and a String takes its
# own count and sum (a checksum, whose block is not called).

def t
  yield
rescue NoMethodError => e
  puts "#{e.message} #{e.args.inspect}"
end

k = ARGV.size
[nil, 5, 2.5, true, :sy].each do |v|
  b = [v, [1, 2]][k]
  t { p b.count(1) }
  t { p b.sum(10) }
  t { p b.sum { |x| x } }
  t { p b.sum(3) { |x| x } }
end

log = []
n = [nil, [1]][k]
t { p n.sum((log << :init; 0)) { |x| x } }
p log

[[1, 2, 1], {a: 1}, 1..4, "abca"].each do |v|
  b = [v, nil][k]
  p(v.is_a?(String) ? b.count("a") : b.count(1))
  p b.sum(0) unless v.is_a?(Hash) || v.is_a?(String)
  p b.sum { |x| 1 }
  p b.sum(1) { |x| 2 } unless v.is_a?(String)
  p b.sum(8) { |x| 2 } if v.is_a?(String)
end
