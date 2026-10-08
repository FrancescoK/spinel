# Under --share-strings (#6765), a String parameter an --rbs signature
# types takes the shared handle when its class is shared, as an inferred
# String parameter does: the seed says what the parameter holds, a String,
# and not how C holds it. The rule refused each of these ("a variable
# cannot hold the shared handle yet"). A nil through the identity method
# raises NoMethodError on the mutator, as it does without the flag.
# spinel: rbs-seed-check
def shrbs_id(x) = x

def shrbs_bang(x)
  x << "!"
  x
end

def shrbs_pair(a, b)
  a << b
  b
end

def shrbs_m(k)
  r = shrbs_id(k == 0 ? +"Hello" : nil)
  r.upcase!
  r
end

p shrbs_m(0)
begin
  shrbs_m(1)
rescue NoMethodError => e
  puts e.message
end

s = +"a"
t = shrbs_id(s)
t << "b"
p [s, t, s.equal?(t)]
u = shrbs_bang(s)
u << "c"
p [s, u, s.equal?(u)]
v = +"v"
w = shrbs_pair(v, s)
w << "d"
p [v, s, w]
q = shrbs_id(s)
q.upcase!
p s
p shrbs_id(nil)
