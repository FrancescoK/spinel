# An Integer Range written with a Float end is eql? to the same Range, and
# not to one whose end is an Integer.
r = (0..1.0)
s = (0..1.0)
p r.eql?(0..1.0)
p r.eql?(s)
p r == (0..1.0)
p (0..1.0).eql?(0..1.0)
p r.eql?(0..1)
p (0..1).eql?(0..1.0)
p (0..1).eql?(0.0..1)
p r.eql?(0...1.0)
p (0..1).eql?(0..1)
