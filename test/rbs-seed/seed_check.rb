# An --rbs seed is trusted, never verified: the analyzer pins the slot and
# codegen narrows whatever arrives into it, so a signature the program
# contradicts reinterprets the value rather than degrading to the inferred
# type. Under -DSP_RBS_CHECK the narrowing sites carry a tag assertion and the
# program aborts at the store instead.
#
# This file is the HONEST half -- every seed here describes what the program
# actually does, so it must run identically with and without the define. The
# dishonest half cannot be a snapshot test (it aborts by design); the Makefile
# runs it separately and asserts that it does abort.
# spinel: rbs-seed-check
class Row
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

  def s=(v)
    @s = v
  end

  def s
    @s
  end
end

def take(x)
  x
end

# values arrive boxed, out of a poly container, so each store is a real
# narrowing -- the only place a seed's truth is checkable at run time
vals = [1, "two", 3.5]

r = Row.new
r.n = vals[0]
p r.n
r.s = vals[1]
p r.s

p take(vals[0])

# a nil always passes the assertion: an unset slot reads nil, and a
# non-nullable seed still sees `@x = nil` in an initialize
r2 = Row.new
p r2.n
p r2.s

# a float slot, so more than one tag is exercised
class FRow
  def initialize
    @f = nil
  end

  def f=(v)
    @f = v
  end

  def f
    @f
  end
end

fr = FRow.new
fr.f = vals[2]
p fr.f
