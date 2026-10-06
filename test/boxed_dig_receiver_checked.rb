# dig on a boxed receiver that cannot be dug (nil, a Symbol, a String, a
# Range, a number): the call is CRuby's NoMethodError, with the keys as
# its args, where it raised the TypeError a step's value raises; a splat
# of keys on nil answered nil. A value met part way still raises that
# TypeError, and nil part way ends the walk.

def t
  p yield
rescue NoMethodError => e
  puts "#{e.message} #{e.args.inspect}"
rescue => e
  puts "#{e.class}: #{e.message}"
end

k = ARGV.size
keys = [[1], 0][k]
[nil, :sy, "s", 1..2, 3, 2.5, [[1, "x"]], {a: {b: 1}}].each do |v|
  n = [v, 0][k]
  t { n.dig(1) }
  t { n.dig(:a, :b) }
  t { n.dig(*keys) }
  t { n.dig(*keys, 0) }
  t { n.dig(0, 1, 0) }
end
