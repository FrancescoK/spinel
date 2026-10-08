# A constant mapped from a literal table of Integer rows holds its rows as
# Integer arrays only where nothing reaches a row but an index. The check
# went by reads of the constant's bare name, reads of an instance variable
# by name and calls of a method by name: a row reached another way took no
# other kind of element, or the store went to a copy.

# the constant through a path
module Pathed
  ROWS = [[1, 2], [3, 4]].map { |a| a.map { |n| n * 2 } }
  def self.cell(i, j) = ROWS[i][j]
end
x = Pathed::ROWS[0]
x[0] = 2.5
p Pathed.cell(0, 0), Pathed::ROWS[0][0]

# the constant by const_get
module Got
  TABLE = [[1, 2], [3, 4]].map { |a| a.map { |n| n + 1 } }
  def self.cell(i, j) = TABLE[i][j]
end
y = Got.const_get(:TABLE)[1]
y[1] = 0.5
p Got.cell(1, 1)

# a row held in an instance variable, handed out by a reader
READ = [[1, 2], [3, 4]].map { |a| a.map { |n| n * 3 } }
class Reader
  attr_reader :held
  def initialize; @held = READ[0]; end
  def cell(j) = @held[j]
end
r = Reader.new
r.held << "s"
p READ[0][2], r.cell(2)

ACCESSED = [[1, 2], [3, 4]].map { |a| a.map { |n| n - 1 } }
class Accessor
  attr_accessor :kept
  def initialize; @kept = ACCESSED[1]; end
  def cell(j) = @kept[j]
end
ac = Accessor.new
ac.kept[0] = 2.5
p ACCESSED[1][0], ac.cell(0)

# the write ends a method, and the method's value is taken by an alias
ALIASED = [[1, 2], [3, 4]].map { |a| a.map { |n| n * 5 } }
class Aliased
  def pick(i)
    @row = ALIASED[i]
  end
  alias pick_too pick
  def cell(j) = @row[j]
end
al = Aliased.new
al.pick_too(1) << "s"
p ALIASED[1][2], al.cell(2)

# by Kernel#Array, which calls to_a by itself
CONVERTED = [[1, 2], [3, 4]].map { |a| a.map { |n| n * 7 } }
class Converted
  def to_a
    @cells = CONVERTED[0]
  end
  def cell(j) = @cells[j]
end
cv = Converted.new
Array(cv) << :z
p CONVERTED[0][2], cv.cell(2)

# by a method of the program's own that answers what its block answers
YIELDED = [[1, 2], [3, 4]].map { |a| a.map { |n| n + 10 } }
class Each
  def each = yield(1)
end
class Yielded
  def choose(i)
    @line = YIELDED[i]
  end
  def cell(j) = @line[j]
end
yd = Yielded.new
got = Each.new.each { |i| yd.choose(i) }
got << 1.5
p YIELDED[1][2], yd.cell(2)

# by super
SUPERED = [[1, 2], [3, 4]].map { |a| a.map { |n| n + 20 } }
class Base
  def take(i)
    @taken = SUPERED[i]
  end
  def cell(j) = @taken[j]
end
class Derived < Base
  def take(i)
    t = super
    t << nil
    0
  end
end
dv = Derived.new
dv.take(0)
p SUPERED[0].size, dv.cell(1)

# by `||=`, which reads through the method
ORREAD = [[1, 2], [3, 4]].map { |a| a.map { |n| n + 30 } }
class OrRead
  def slot
    @slot = ORREAD[1]
  end
  def slot=(v); end
  def cell(j) = @slot[j]
end
ow = OrRead.new
(ow.slot ||= 5) << "t"
p ORREAD[1][2], ow.cell(2)

# a store through the path itself, and through a reader given as a block
module Pushed
  ROWS2 = [[1, 2], [3, 4]].map { |a| a.map { |n| n * 2 } }
  def self.cell(i, j) = ROWS2[i][j]
end
Pushed::ROWS2[1] << "s"
Pushed::ROWS2.each { |row| row << 1.5 }
p Pushed.cell(1, 2), Pushed.cell(0, 2), Pushed.cell(1, 3)

MAPPED = [[1, 2], [3, 4]].map { |a| a.map { |n| n * 9 } }
class Mapped
  attr_reader :cells2
  def initialize; @cells2 = MAPPED[0]; end
  def cell(j) = @cells2[j]
end
m = Mapped.new
[m].map(&:cells2).each { |row| row << "u" }
p MAPPED[0][2], m.cell(2)

# a Method object, instance_variable_get, and `super` as a receiver
BOUND = [[1, 2], [3, 4]].map { |a| a.map { |n| n + 40 } }
class Bound
  def fetch_row(i)
    @bound = BOUND[i]
  end
  def cell(j) = @bound[j]
end
b = Bound.new
b.method(:fetch_row).call(1) << "v"
p BOUND[1][2], b.cell(2)

IVGOT = [[1, 2], [3, 4]].map { |a| a.map { |n| n + 50 } }
class IvGot
  def initialize; @got = IVGOT[0]; end
  def cell(j) = @got[j]
end
ig = IvGot.new
ig.instance_variable_get(:@got) << "w"
p IVGOT[0][2], ig.cell(2)

SUPERPUSH = [[1, 2], [3, 4]].map { |a| a.map { |n| n + 60 } }
class Base2
  def lift(i)
    @lifted = SUPERPUSH[i]
  end
  def cell(j) = @lifted[j]
end
class Derived2 < Base2
  def lift(i)
    super << 1.5
    nil
  end
end
d2 = Derived2.new
d2.lift(1)
p SUPERPUSH[1][2], d2.cell(2)

# as before: rows only read by an index, through a path too
module Plain
  CLOCKS = [[7, 8], [9, 10 + 1]].map { |a| a.map { |n| 12 * n } }
  def self.sum(i) = CLOCKS[i][0] + CLOCKS[i][1]
end
class Counter
  def initialize; @clocks = Plain::CLOCKS[0]; end
  def pick(i)
    @clocks = Plain::CLOCKS[i]
  end
  def step(k) = @clocks[k] * 2
end
c = Counter.new
c.pick(1)
p Plain.sum(0), Plain::CLOCKS[1][1], c.step(1)
