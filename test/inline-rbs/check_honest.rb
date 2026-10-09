# The honest half of the -DSP_RBS_CHECK pair for inline RBS: every annotation
# describes what the program does, so the program runs identically with and
# without the define. check_false.rb is the dishonest half.

class Row
  # @rbs @n: Integer?

  attr_accessor :s #: String?

  def initialize
    @n = nil
    @s = nil
  end

  def n=(v)
    @n = v
  end

  def n
    @n
  end

  #: (Integer) -> Integer
  def take(x)
    x
  end
end

# values arrive boxed, out of a poly container, so each store is a real
# narrowing -- the only place an annotation's truth is checkable at run time
vals = [1, "two", 3.5]

r = Row.new
r.n = vals[0]
p r.n
r.s = vals[1]
p r.s
p r.take(vals[0])
