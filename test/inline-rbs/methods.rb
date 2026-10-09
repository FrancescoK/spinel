# Inline RBS method signatures, one method per form. Every annotation pins a
# slot to a type inference would not choose on its own (`untyped` where every
# caller passes an untyped), so the generated C shows whether it applied, and
# the same program compiled with `--no-inline-rbs --rbs sig/methods` must
# produce the same C byte for byte.

class Calc
  #: (untyped) -> untyped
  def m1(x)
    x
  end

  #: () -> void
  def m2
    @last = 2
  end

  # @rbs (untyped) -> untyped
  def m3(x)
    x
  end

  #: (untyped,
  #   untyped) -> untyped
  def m7(x, y)
    x + y
  end

  # @rbs (untyped,
  #   untyped) -> untyped
  def m8(x, y)
    x + y
  end

  # Adds the two, documented the rbs-inline way.
  #
  # @rbs x: untyped
  # @rbs y: untyped
  # @rbs return: untyped
  def m9(x, y)
    x + y
  end

  # @rbs a: untyped
  # @rbs k: untyped
  # @rbs return: untyped
  def m9k(a, k:)
    a + k
  end

  # @rbs x: untyped
  def m11(x) #: untyped
    x
  end

  # @rbs x: untyped
  # @rbs return: untyped
  def m12(x) = x

  #: (untyped) -> untyped
  def adjacent_signature(x)
    x
  end

  #: (untyped) -> untyped
  private def priv(x)
    x
  end

  def call_priv(x)
    priv(x)
  end

  #: (untyped) -> untyped
  def self.m13(x)
    x
  end

  class << self
    def m14(x)
      x
    end
  end

  # @rbs skip
  def m15(x)
    x
  end
end

def top_level(x)
  x
end

c = Calc.new
p c.m1(1)
c.m2
p c.m3(3)
p c.m7(3, 4)
p c.m8(4, 4)
p c.m9(4, 5)
p c.m9k(5, k: 5)
p c.m11(11)
p c.m12(12)
p c.adjacent_signature(13)
p c.call_priv(14)
p Calc.m13(13)
p Calc.m14(14)
p c.m15(15)
p top_level(16)
