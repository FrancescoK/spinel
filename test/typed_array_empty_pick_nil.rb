# delete_at / slice!(i) out of range, sample on an empty array, rfind that
# finds nothing, and inject / reduce without an initial value on an empty
# array all answer nil. Leftovers of #4288, which fixed pop and shift:
#
# The Float array's delete_at (which slice!(i) shares) answered 0.0, and
# every typed array's sample answered a zero element (0, 0.0, ""), where
# the slot's own nil sentinel is what pop and shift answer.
#
# rfind seeded its no-match answer with 0 on a Float array.
#
# And slice!(i) and an inject without an initial value were not known to
# leave the sentinel, so a local holding one boxed it as a number: the
# Float one printed NaN, the Integer one printed nil but answered false to
# nil?.

def nil_q(x) = x.nil?

class Box
  attr_accessor :v
end

f = [1.5, 2.5]
i = [1, 2]
s = ["a", "b"]
fe = [1.5]; fe.clear
ie = [1]; ie.clear
se = ["a"]; se.clear

# direct
p f.delete_at(7), f.slice!(7), fe.delete_at(0), fe.slice!(0)
p fe.sample, ie.sample, se.sample
p fe.rfind { |x| x > 0 }, f.rfind { |x| x > 9 }, i.rfind { |x| x > 9 }, s.rfind { |x| x == "z" }
p fe.inject(:+), fe.reduce { |m, x| m + x }, ie.inject(:+)

# through a local
a = fe.inject(:+); p a, a.nil?
b = fe.reduce(:+); p [b, b.nil?]
c = ie.inject(:+); p [c, c.nil?]
d = ie.slice!(9); p [d, d.nil?]
e = fe.slice!(0); p [e, e.nil?]
g = fe.inject { |m, x| m + x }; p g.nil?
w = "s"
w = ie.slice!(0); p w.nil?
w = ie.inject(:+); p w.nil?
w = fe.inject(:+); p [w, :x]

# as an argument, a stored value, an element, an interpolation, an `||`
p nil_q(f.slice!(7)), nil_q(fe.sample), nil_q(ie.sample), nil_q(se.sample)
bx = Box.new
bx.v = fe.sample
p bx.v
p({ k: fe.delete_at(0) })
p [fe.sample, ie.sample, se.sample, f.rfind { |x| x > 9 }]
puts "#{fe.sample.inspect} #{ie.sample.inspect} #{se.sample.inspect}"
p(fe.sample || 9.5)
p(ie.inject(:+) || 7)

# a hit still answers the element, and an initial value still answers it
p f.rfind { |x| x < 2 }, f.inject(:+), i.inject(:*), f.delete_at(0), f
p fe.inject(10.0) { |m, x| m + x }, ie.inject(3, :+)

# a typed array held in a poly value
[fe, ie, se, [1.5, 2.5]].each do |v|
  p [v.sample.nil?, v.delete_at(9), v.slice!(9), v.inject(:+).nil?]
end
