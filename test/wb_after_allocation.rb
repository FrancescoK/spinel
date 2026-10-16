# spinel: gc-stress
# A store into an object that an allocation since its creation may have made
# old takes the write barrier after that allocation. JSON.parse's
# symbolize_names, a merged Hash with a default block, Addrinfo, a copy of an
# Object with instance variables, Exception#exception on a class with
# instance variables, a Hash's default= and the each_slice / cycle
# enumerators each recorded the store before the allocation, or not at all:
# under SPINEL_GC_STRESS=2 the next minor collection freed the value the old
# object still held.
require "json"
require "socket"
p JSON.parse('[{"a":1},{"b":[{"c":2}]},{"d":3}]', symbolize_names: true)
h = Hash.new { |hh, k| hh[k] = 1 }
m = h.merge({b: 2})
m[:a]
p h, m
ai = Addrinfo.tcp("127.0.0.1", 80)
p ai.ip_address, ai.afamily == Socket::AF_INET, ai.inspect
o = Object.new
o.instance_variable_set(:@a, [1, 2])
d = o.dup
d.instance_variable_set(:@b, "two")
p d.instance_variable_get(:@a), d.instance_variables
class E < StandardError
  def initialize(m)
    super
    @x = [m]
  end
  attr_reader :x
end
e = E.new("a").exception("b")
p e.message, e.x
t = [{}, 1][0]
t.default = "d#{t.size}"
p t[:missing], t.default
s = {"k" => "v"}
s.default = "w#{s.size}"
p s["x"]
p [1, 2, 3].each_slice(2), [1, 2].cycle(2)
