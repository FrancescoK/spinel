# match? and match on a boxed receiver: a value with no such method raises
# CRuby's NoMethodError (with the call's arguments), a String's or a
# Symbol's pattern of the wrong kind its TypeError, and a Regexp's subject
# of the wrong kind its TypeError, where the poly helpers answered no
# match. match?(pattern, pos) on a boxed String or Symbol takes the
# position, and the position runs before the receiver is judged.

def t
  p yield
rescue NoMethodError => e
  puts "#{e.message} #{e.args.inspect}"
rescue => e
  puts "#{e.class}: #{e.message}"
end

def pos(x)
  puts "pos"
  x
end

k = ARGV.size
[nil, 5, [1, 2], :sy, "sa", 2.5, {a: 1}].each do |v|
  n = [v, 0][k]
  t { n.match?("a") }
  t { n.match?(/a/) }
  t { n.match?("a", 1) }
  t { n.match("a") }
  t { n.match?(/a/, pos(1)) }
end
[/a/, "sa", :sa, nil].each do |v|
  r = [v, 0][k]
  t { r.match?(nil) }
  t { r.match?(:a) }
  t { r.match?(1) }
  t { r.match(nil) }
  t { r.match?("a", 1) }
  t { r.match?("a", 2) }
  t { r.match?(/a/, 1) }
end
