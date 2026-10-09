# Inline RBS that Spinel recognises but does not apply. Each annotation gets a
# warning naming its line and saying it is ignored, and nothing of it is
# applied: the C is the C of the same program compiled with --no-inline-rbs.
require_relative "warnings_part"

class Shapes
  #: (1) -> Integer
  def literal(x)
    x
  end

  #: (_Each) -> void
  def interface(x)
    x
  end

  #: (?Integer) -> Integer
  def optional(x = 1)
    x
  end

  #: () -> Integer
  #: (Integer) -> Integer
  def overloaded(x = 0)
    x
  end

  # @rbs (Integer) -> Integer
  #    | (String) -> String
  def overloaded2(x)
    x
  end

  #: [U] (U) -> U
  def generic(x)
    x
  end

  # @rbs *rest: Integer
  def splat(*rest)
    rest.size
  end

  def locals
    a = 1 #: Integer
    b = [a].first
    c = [b].first
    d = [c].first
    a + b + c + d
  end

  #: () -> Integer

  def inner
    # @rbs @inner: String
    @inner = "x" #: Integer
  end

  attr_reader "named" #: String
end

LIMIT = 10 #: Integer

#: () -> Integer

z = 3

s = Shapes.new
p s.literal(1)
p s.interface([1])
p s.optional
p s.overloaded
p s.overloaded2(2)
p s.generic(3)
p s.splat(1, 2)
p s.locals
p s.inner
p LIMIT + z
p part_value

# A mixed array widens h during analysis. This unsupported local annotation
# must leave h["x"] using its inferred representation.
vals = [{"x" => 1}, "s"]
h = vals[0] #: Hash[String, Integer]
p h["x"]

#: () -> Integer
