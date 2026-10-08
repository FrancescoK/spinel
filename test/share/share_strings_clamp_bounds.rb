# A clamp can return either bound as well as its receiver. Each selected
# value retains its identity, including through returns and containers.
def clamp_return(s, lo, hi)
  s.clamp(lo, hi)
end

def clamp_explicit(s, lo, hi)
  return s.clamp(lo, hi)
end

s = +"m"
lo = +"n"
hi = +"z"
t = s.clamp(lo, hi)
p [t.equal?(lo), t.frozen?]
t << "!"
p [s, lo, hi, t]
s = +"z"
lo = +"a"
hi = +"n"
t = s.clamp(lo, hi)
p t.object_id == hi.object_id
hi.replace("upper")
p [s, lo, hi, t]
s = +"middle"
t = clamp_return(s, "a", "z")
t.upcase!
p [s, t, s.equal?(t)]
t = clamp_explicit(s, "A", "Z")
t << "!"
p [s, t, s.equal?(t)]

s = +"m"
a = [s.clamp("a", "z")]
a[0].replace("array")
p [s, a, s.equal?(a[0])]
h = {v: s.clamp(nil, nil)}
h[:v] << "!"
p [s, h, s.equal?(h[:v])]

s = +"m"
t = s.clamp("a".."z")
t << "!"
p [s, t, s.equal?(t)]
s = +"m"
t = s.clamp("a"..)
t << "!"
p [s, t, s.equal?(t)]
s = +"m"
t = s.clamp(.."z")
t << "!"
p [s, t, s.equal?(t)]
s = +"m"
t = s.clamp("a"...)
t << "!"
p [s, t, s.equal?(t)]

# Bounds are evaluated once in order, and may mutate the chosen receiver.
$clamp_events = +""
def clamp_operand(label, value)
  $clamp_events << label
  value
end
s = +"m"
t = clamp_operand("r", s).clamp(clamp_operand("l", "a"), clamp_operand("h", "z"))
t << "!"
p [$clamp_events, s, t, s.equal?(t)]

# Fresh allocating operands survive later argument evaluation.
t = ("m#{ARGV.size}").clamp("a#{ARGV.size}", "z#{ARGV.size}")
t << "!"
p t

# Equal content does not make two Strings the same operand.
s = +"m"
lo = +"m"
t = s.clamp(lo, "z")
p [t.equal?(s), t.equal?(lo)]
t << "!"
p [s, lo, t]

# Invalid bounds still raise, and nil remains an open side.
begin
  s.clamp("z", "a")
rescue => e
  p e.class
end
begin
  s.clamp("a"..."z")
rescue => e
  p e.class
end

lo = +"b"
hi = +"y"
t = "a".clamp(lo..hi)
t << "!"
p [lo, t, lo.equal?(t)]
t = "z".clamp(lo..hi)
hi << "!"
p [hi, t, hi.equal?(t)]
s = +"m"
t = s.clamp("a", "z").clamp("a", "z")
t << "!"
p [s, t, s.equal?(t)]
$s = +"m"
t = $s.clamp("a", "z")
t << "!"
p [$s, t, $s.equal?(t)]
a = [+"m"]
t = a[0].clamp("a", "z")
t << "!"
p [a, t, a[0].equal?(t)]
h = {v: +"m"}
t = h[:v].clamp("a", "z")
t << "!"
p [h, t, h[:v].equal?(t)]

# A boxed receiver still returns its original String operand.
def boxed_clamp(v)
  v.clamp(nil, nil)
end
s = +"abc"
t = boxed_clamp(s)
t << "!"
p [s, t, s.equal?(t)]
p boxed_clamp(5)
