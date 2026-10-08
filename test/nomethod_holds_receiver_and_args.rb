# A NoMethodError keeps the receiver and the arguments of the call that
# failed. The helper that builds it allocated the list of the arguments
# first: a receiver or an argument that is a temporary was held by nothing
# during that allocation, and the error took a freed value. One of
# GC_STRESS_TESTS: each call below aborted at SPINEL_GC_STRESS=2.

def id(s) = s
def mk(x) = [x, 1]
def pick(c, x) = c ? 5 : [x, 2]

c = ARGV.size > 5
x = id("bc")
r = c ? "s" : 5

# the receiver is a temporary
begin
  pick(c, x).zork(1)
rescue NoMethodError => e
  p e.receiver, e.args
end
begin
  pick(c, x).zork
rescue NoMethodError => e
  p e.receiver, e.args
end
begin
  pick(c, x).chr
rescue NoMethodError => e
  p e.receiver, e.args
end
begin
  pick(c, x).next_float
rescue NoMethodError => e
  p e.receiver
end

# an argument is a temporary: on a boxed receiver, an Integer, an Array
begin
  r.zork("a" + x)
rescue NoMethodError => e
  p e.receiver, e.args
end
begin
  r.zork("v=#{x}", [x, 1])
rescue NoMethodError => e
  p e.receiver, e.args
end
begin
  r.zork(mk(x))
rescue NoMethodError => e
  p e.receiver, e.args
end
begin
  5.zork("a" + x)
rescue NoMethodError => e
  p e.args
end
begin
  mk(x).zork("a" + x)
rescue NoMethodError => e
  p e.receiver, e.args
end
begin
  [x + "d"].zork(x + "e")
rescue NoMethodError => e
  p e.receiver, e.args
end
