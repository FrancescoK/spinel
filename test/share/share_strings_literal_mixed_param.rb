# A boxed parameter's literal store keeps its lift when a String can reach
# it, even if other callers pass Integers or Ranges.
def wrap(value)
  [value]
end

p wrap(7), wrap(2..4)
s = +"a\0b"
t = wrap(s)[0]
t << "c"
p s.equal?(t), [s, t]

f = "frozen"
u = wrap(f)[0]
p f.equal?(u), u.frozen?
begin
  u << "x"
rescue => e
  p e.class
end
p [f, u]
