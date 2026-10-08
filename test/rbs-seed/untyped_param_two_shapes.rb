# An `untyped` parameter is a poly seed: inference may narrow it from ONE call
# site's evidence (the body reads value[:value], which reads as a symbol-keyed
# hash), and that narrowing must not be trusted the way a declaration is. It was
# -- so a String-passing caller had its pointer reinterpreted, and the program
# segfaulted with no diagnostic (#3977).
# spinel: rbs-seed-run
class Box
  def self.value_of(value)
    return value[:value].to_s if value.is_a?(Hash)
    value.to_s
  end
end

class HolderShapes
  def initialize
    @store = {}
  end

  def []=(key, value)
    @store[key.to_s] = Box.value_of(value)
    value
  end

  def [](key)
    @store[key.to_s]
  end
end

h = HolderShapes.new
h[:a] = { value: "from-hash", extra: true }
h[:b] = "from-string"
puts h[:a]
puts h[:b]
puts Box.value_of("direct")
puts Box.value_of({ value: "direct-hash" })
