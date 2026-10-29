# A def among a call's operands (an argument, the block argument, an
# argument's receiver, an earlier argument of the call around it) runs
# before the call, which then calls it, at the top level and in a class
# body.
def mark(x) = (puts "mark #{x}"; x)
p foo(mark(1), &(def foo(*a) = 9; nil))
p bar((def bar(*a) = 7; 1))
p qq2((def qq2(*a) = 2).to_s)
p((def qq(*a) = 6; 1), qq)

class U
  def self.mark(x) = (puts "mark #{x}"; x)
  p baz(mark(1), &(def self.baz(*a) = 5; nil))
  x = bz(mark(2), &(def self.bz(*a) = 4; nil))
  p x
end
