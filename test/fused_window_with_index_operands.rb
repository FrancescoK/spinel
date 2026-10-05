# The fused each_cons / each_slice / with_index chains take a count or
# offset that hoists statements of its own (a call through a method with a
# default argument) and a proc's boxed index parameter. The operand's
# statements landed in the middle of the count's C line, and the index was
# stored raw into the boxed slot: the C did not build.
def w(v, d = nil) = v
$c = 0
def step = ($c += 1)
p 4.times.map { step }.each_cons(w(2)).map { |a, b| b - a }
p 4.times.map { step }.each_cons(2).with_index(w(1)).map { |(x, y), i| [x - y, i] }
p [1, 2, 3].map { |v| v * 2 }.each_cons(2).with_index(1).map(&proc { |(x, y), i| [x - y, i] })
p 5.times.map { step }.each_slice(w(2)).map { |a| a.sum }
if "ab12" =~ /(\d)(\d)/
  p $~[w(1)], Regexp.last_match(w(2))
end
p $c
