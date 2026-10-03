# Proc#=== and Proc#yield are calls: their argument types the proc's
# parameters the way #call does. Called only through ===, the parameter kept
# the Integer default, so `t.size` on a String answered 8 and a Float was
# truncated.
size = proc { |t| t.size }
p size === "four"

up = proc { |t| t.upcase }
p up === "four"

inc = proc { |t| t + 1 }
p inc === 2.5

sym = proc { |t| t.to_s + "!" }
p sym.yield(:sym)

ivar_holder = Class.new do
  def initialize; @pr = proc { |s| s.reverse }; end
  def run; @pr === "abc"; end
end
p ivar_holder.new.run
