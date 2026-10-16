# Module.new without a block makes a module like `Module.new {}` does: a
# constant holding one is defined (a sentinel default `NONE = Module.new`),
# and one not yet assigned to a constant is anonymous -- name nil, shown as
# #<Module:0x...> -- until a constant write names it.
m = Module.new
p m.name, m.inspect.start_with?("#<Module:0x"), m.to_s == m.inspect
M2 = m
p m.name, m, M2.to_s
q = Module.new do
  def self.hi = "hi"
  def inst = "inst"
end
p q.hi, q.name, q.to_s.start_with?("#<Module:0x")
module Outer
  Inner = Module.new
end
p Outer::Inner, Outer::Inner.name
module Opt
  NONE = Module.new
  def self.pick(a = NONE, b: NONE) = [a.equal?(NONE), b == NONE]
end
p Opt.pick, Opt.pick(1), Opt.pick(b: 2)
h = { Opt::NONE => :none }
p h[Opt::NONE], Opt::NONE.frozen?, Opt::NONE.instance_of?(Module)
