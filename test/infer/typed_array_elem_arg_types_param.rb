# An array's element type is only known after the fixpoint: while the array is
# still the boxed kind, every read of it answers poly. A LOCAL that took that
# answer is repaired once the array narrows (`b = arr[i]`), but a PARAMETER
# handed the same expression was not -- `f(arr[i])` bound the poly, the later
# narrowing never reached it, and the callee boxed every use of a value the
# caller holds unboxed. `@col[q]` passed on made `wcol * 4` a boxed multiply
# with a GC root slot beside a local holding that same element as a machine int.
#
# Correctness was never at stake here, only the representation, so the values
# below are what CRuby prints either way. What the test pins is that the
# program still computes them once the parameter is narrowed.
class Plan
  def initialize
    @col = Array.new(0, 0)
    @nm  = []
    @buf = "\0" * 64
  end

  def add(c, n)
    @col << c
    @nm << n
    0
  end

  # the reported shape: an element of a typed ivar array, straight into a call
  def build(q)
    write_column(@col[q])
  end

  def write_column(wcol)
    @buf.setbyte(wcol * 4, 7)
    wcol * 2
  end

  # the same through a local, which is what the caller's own repair produces
  def build_local(q)
    w = @col[q]
    write_column(w)
  end

  # a String array's element, so the rule is not read as Integer-only
  def build_n(q)
    shout(@nm[q])
  end

  def shout(s)
    s.length
  end

  # first/last read the same element, and are the other arm of the rule
  def build_first
    write_column(@col.first)
  end

  def at(i)
    @buf.getbyte(i)
  end
end

p1 = Plan.new
p1.add(1, "ab")
p1.add(3, "cde")
p p1.build(0)
p p1.build_local(1)
p p1.build_n(1)
p p1.build_first
p p1.at(4)

# A parameter whose call sites DISAGREE keeps the boxed slot: the rule asks
# that every argument be an element read of the same kind, exactly as the
# local rule asks it of every write.
class Mixed
  def initialize
    @i = Array.new(0, 0)
    @f = Array.new(0, 0.0)
  end
  def add(a, b)
    @i << a
    @f << b
    0
  end
  def from_i(q)
    take(@i[q])
  end
  def from_f(q)
    take(@f[q])
  end
  def take(v)
    v.to_s
  end
end

m = Mixed.new
m.add(4, 0.5)
p m.from_i(0)
p m.from_f(0)
