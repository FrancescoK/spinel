# `recv[k] ||= v`, `recv[k] &&= v` and `recv[k] += v` on a USER-class
# receiver defining [] and []= (a registry wrapping a Hash), in statement
# and expression position; only the builtin containers were lowered.
class Registry
  def initialize = @h = {}
  def [](k) = @h[k]
  def []=(k, v)
    @h[k] = v
  end
  def keys = @h.keys
end
r = Registry.new
r[:a] ||= 1
r[:a] ||= 2
p r[:a]
got = (r[:b] ||= "first")
p got, (r[:b] ||= "second")
r[:a] += 10
p r[:a], (r[:a] += 1)
r[:b] &&= "and"
p r[:b]
r[:none] &&= "never"
p r[:none], r.keys
class Counter
  def initialize = @reg = Registry.new
  def hit(k) = @reg[k] ||= 0
  def bump(k) = (@reg[k] += 1)
  def reg = @reg
end
c = Counter.new
c.hit(:x)
c.bump(:x)
p c.bump(:x), c.reg[:x]
