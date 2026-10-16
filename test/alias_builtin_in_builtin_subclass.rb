# An alias, in a class deriving from Hash, Array or String, of a method the
# builtin answers (rack's `alias_method :to_params_hash, :to_h` on its
# Hash-derived Params) calls that method with the arguments it is given.
# The alias was a forwarder splatting its arguments into a bare call, and
# a splat into a builtin outside the few names the length dispatch lists
# compiled to a NoMethodError. A call on a receiver known to be of the
# class, or inside it, now names the builtin method itself.
class Params < Hash
  alias_method :to_params_hash, :to_h
  alias_method :lookup, :fetch
  alias count_keys size

  def plain = to_params_hash
end

class Row < Array
  alias_method :ordered, :sort
  alias_method :pick, :first
end

class Text < String
  alias_method :loud, :upcase
end

h = Params.new
h["a"] = 1
p h.to_params_hash, h.count_keys, h.plain
p h.lookup("a"), h.lookup("b", 2), h.lookup("c") { |k| k * 2 }
begin
  h.lookup("b")
rescue KeyError => e
  p e.class
end

r = Row.new([3, 1, 2])
p r.ordered, r.ordered { |a, b| b <=> a }, r.pick, r.pick(2)
p Text.new("hey").loud
