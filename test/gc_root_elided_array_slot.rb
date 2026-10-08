# A poly local proven to hold only a poly array or nil does not need a GC root:
# its index read takes the runtime's inline array arm, which neither allocates
# nor re-enters Ruby, so the element stays reachable from the container it was
# read out of. Codegen drops the root for that local, which is what lets the
# C compiler keep it in a register. The shape below is optcarrot's sprite map:
# a nil-filled table whose entries are handed out of a preallocated buffer.
# spinel: decisions
class Sprites
  def initialize(n)
    @map = [nil] * n
    @buf = (0...n).map { [false, false, 0] }
    @n = n
  end

  def clear
    @n.times { |i| @map[i] = nil }
  end

  def place(i, behind, zero, colour)
    s = @map[i] = @buf[i]
    s[0] = behind
    s[1] = zero
    s[2] = colour
    s
  end

  # the read whose root the elision targets: `s` is nil or one of @buf's rows
  def pixel(i, base)
    out = base
    s = @map[i]
    if s
      out = s[2] if base % 4 == 0
      out = s[2] unless s[0]
      out = -out if s[1]
    end
    out
  end
end

sp = Sprites.new(8)
p sp.pixel(0, 4)
sp.place(0, false, false, 9)
sp.place(3, true, false, 7)
sp.place(5, false, true, 6)
p sp.pixel(0, 4)
p sp.pixel(3, 4)
p sp.pixel(5, 4)
p sp.pixel(1, 4)
p sp.pixel(0, 5)

# the same reads with a collection forced between them: an elided root must not
# have been the only thing keeping the row alive
GC.start
p sp.pixel(0, 4)
junk = []
200.times { |k| junk << "pressure #{k}" * 4 }
GC.start
p sp.pixel(3, 4)
p sp.pixel(5, 4)
p junk.length

sp.clear
p sp.pixel(0, 4)
sp.place(2, false, false, 3)
GC.start
p sp.pixel(2, 4)

# The destructuring shape, where the value lives in a temp rather than a named
# local: a pair read out of a frozen lookup table and split across two slots.
# The temp's proof has to come out of the container ivar, which is filled from
# a hash whose values are array literals.
class Lut
  def initialize(n)
    entries = {}
    @lut = (0...n).map { |i|
      entries[i] ||= [i * 2, i * 3]
      entries[i]
    }.freeze
    @a = 0
    @b = 0
  end

  def load(i)
    @a, @b = @lut[i]
    @a + @b
  end
end

lut = Lut.new(6)
p lut.load(0)
p lut.load(4)
GC.start
p lut.load(4)
noise = []
150.times { |k| noise << [k, "s#{k}"] }
GC.start
p lut.load(5)
p noise.length
