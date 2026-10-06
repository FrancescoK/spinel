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

# the position counts the subject's own bytes: past an embedded NUL, and
# one unit per byte in a binary String
["ab\0cd", "\xC3\xA9x".b].each do |v|
  s = [v, 0][k]
  t { s.match?(/cd/, 1) }
  t { s.match?(/.x/, 1) }
  t { s.match?(/^.x/, 1) }
end

# an object with a #to_str is converted, as a Regexp's subject and as a
# String's or a Symbol's pattern
class StrLike
  def to_str = "needle"
end
o = [StrLike.new, 0][k]
[/needle/, "needle", :needle].each do |v|
  r = [v, 0][k]
  t { r.match?(o) }
  t { r.match(o).to_s }
end

# a third argument is the arity error, whatever the receiver holds
["abc", nil].each do |v|
  s = [v, 0][k]
  t { s.match?(/b/, 0, 1) }
end
