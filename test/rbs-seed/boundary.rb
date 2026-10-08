# Regression for #1417 boundary coercion. Once seeds apply, a method's RBS
# return/param type can be narrower than its poly body value or call-site arg,
# so codegen must unbox the poly at the boundary:
#   - `Slots.get` is RBS `-> String?` but reads a poly hash value (return path);
#     the missing-key case must round-trip nil -> NULL -> nil.
#   - `Slots.flag` is RBS `-> bool` over a poly value (bool return path).
#   - `Slots.list` is RBS `-> Array[Integer]` over a poly value, and `sum` takes
#     `Array[Integer]` -- a non-object pointer-backed type on both the return and
#     argument paths.
#   - `Use.label` takes an RBS `Thing` but is called with a poly array element
#     (object argument path).
# Without the coercion the generated C assigns sp_RbVal to a const char* /
# sp_bool / sp_IntArray* / sp_Thing* slot and fails to compile.
# spinel: rbs-seed-check
module Outer
  class Thing
    def initialize(n)
      @n = n
    end
    def n
      @n
    end
  end
  module Slots
    @h = {}
    def self.set(k, v)
      @h[k] = v
    end
    def self.get(k)
      @h[k]
    end
    def self.flag(k)
      @h[k]
    end
    def self.list(k)
      @h[k]
    end
    def self.sum(a)
      n = 0
      i = 0
      while i < a.length
        n += a[i]
        i += 1
      end
      n
    end
  end
  module Use
    def self.label(t)
      t.n
    end
  end
end

Outer::Slots.set(:x, "hi")
Outer::Slots.set(:f, true)
Outer::Slots.set(:l, [4, 5, 6])
puts Outer::Slots.get(:x)
puts Outer::Slots.get(:y).nil?
puts Outer::Slots.flag(:f)
puts Outer::Slots.sum(Outer::Slots.list(:l))
puts Outer::Use.label([Outer::Thing.new("z")][0])
