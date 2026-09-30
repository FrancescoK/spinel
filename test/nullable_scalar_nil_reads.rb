# A nil in an Integer or a Float slot (the sentinel a missed read leaves) is
# nil to every read of it. nil's own to_a, to_h, =~ and !~, and on a Float
# the boolean &, | and ^, answer as nil does where the receiver's class has
# no such method; a Float's to_r, rationalize and to_c answer (0/1) and
# (0+0i); an operator against the other numeric kind raises as nil does
# rather than computing on the sentinel; a nil block value into `sum { }`
# is the accumulator's coercion failure; and a boxed `case` subject takes a
# `when 0` arm only where `0 === subject`, not nil, "0" or 0.5, whatever the
# labels (INT64_MIN and INT64_MAX among them). An argument is evaluated after
# the receiver, and nil's rationalize takes an epsilon of any kind.
# Integer() of either nil is the TypeError, also under --int-overflow=promote,
# where the call answers a box. nil's answer is a value like any other: a
# call can be made on it too.

def t
  yield
rescue => e
  puts "#{e.class}: #{e.message}"
end

b = [1][ARGV.size + 5]
f = [1.5][ARGV.size + 5]
c = [7][ARGV.size]
g = [2.5][ARGV.size]

p [b.to_a, b.to_h, b =~ /x/, b !~ /x/]
p [f.to_a, f.to_h, f =~ /x/, f !~ /x/]
p [f & 1, f | 1, f ^ nil]
p [f.to_r, f.rationalize, f.rationalize(0.1), f.to_c]
p [f.rationalize("ignored"), f.rationalize(p(0.25)), b.rationalize(p(0.5)), 3.rationalize(p(0.75))]
p [g.to_r, g.to_c]
t { c.to_a }
t { g.to_h }
t { c =~ /x/ }
t { g | 1 }
a = [1.5]
t { p(a.dig(ARGV.size) | [a.clear]) }

t { p(f > 1) }
t { p(b < 2.0) }
t { p(1 < f) }
t { p(1.0 >= b) }
t { p(b + 1.0) }
t { p(1 + f) }
t { p(1.0 * b) }
t { p Integer(f) }
t { p Integer(b) }
p [g > 2, c < 7.5, c + 0.5, 1 + g]

t { p [1.5, [2.5][ARGV.size + 5]].sum { |e| e } }
t { p [1, [2][ARGV.size + 5]].sum(0.0) { |e| e } }
t { p [[1.5][ARGV.size + 5], 2.5].sum { |e| e } }
p [1.5, 2.5].sum { |e| e }

y = [nil, 1][ARGV.size]
w = [0.5, 1][ARGV.size]
s = ["0", 1][ARGV.size]
v = [1.0, 1][ARGV.size]
[y, w, s, :a, v, 0, 1, 2].each do |x|
  case x
  when 0 then p :zero
  when 1 then p :one
  else p :else
  end
end
[y, 1.0, -9223372036854775808, 9223372036854775807].each do |x|
  case x
  when -9223372036854775808 then p :min
  when 9223372036854775807 then p :max
  when 1 then p :one
  else p :else
  end
end

p [b.to_a.size, b.to_h.empty?, (b =~ /x/).inspect, b.to_a.inspect]
p [(f & true).inspect, (f | 1).to_s, (f ^ nil).class, f.to_h.to_a]
t { c.to_a.size }
t { (g & true).inspect }
h = b.to_a
h << 3
p [h, [b.to_a, f.to_h]]
