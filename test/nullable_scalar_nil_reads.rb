# A nil in an Integer or a Float slot (the sentinel a missed read leaves) is
# nil to every read of it. nil's own to_a, to_h, =~ and !~, and on a Float
# the boolean &, | and ^, answer as nil does where the receiver's class has
# no such method; a Float's to_r, rationalize and to_c answer (0/1) and
# (0+0i); an operator against the other numeric kind raises as nil does
# rather than computing on the sentinel; a nil block value into `sum { }`
# over Floats is Float#+'s coercion failure; and a boxed `case` subject takes
# a `when 0` arm only where `0 === subject`, not nil, "0" or 0.5.

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
p [g.to_r, g.to_c]
t { c.to_a }
t { g.to_h }
t { c =~ /x/ }
t { g | 1 }

t { p(f > 1) }
t { p(b < 2.0) }
t { p(1 < f) }
t { p(1.0 >= b) }
t { p(b + 1.0) }
t { p(1 + f) }
t { p(1.0 * b) }
p [g > 2, c < 7.5, c + 0.5, 1 + g]

t { p [1.5, [2.5][ARGV.size + 5]].sum { |e| e } }
t { p [1, [2][ARGV.size + 5]].sum(0.0) { |e| e } }
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
