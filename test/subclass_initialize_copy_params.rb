# initialize_copy hooks dup and clone call with the original alone: a
# second, optional parameter takes its default (a plain class's call left it
# out and the C did not build), and an Array or Hash subclass's hook whose
# parameter the program also hands other values takes the original boxed.
class Plain
  attr_reader :t
  def initialize = @t = 0
  def initialize_copy(o, tag = :copied) = (@t = tag)
end
p Plain.new.dup.t

class Page < Array
  attr_reader :note
  def initialize_copy(src, note = "dup of #{src.size}")
    super(src)
    @note = note
  end
end
pg = Page.new([1, 2, 3])
c = pg.dup
p c, c.class, c.note

class Reg < Hash
  attr_reader :origin
  def initialize_copy(other)
    super
    @origin = other.class
  end
end
r = Reg.new
r[:a] = 1
d = r.clone
p d, d.class, d.origin
r.send(:initialize_copy, {b: 2}) if ARGV.size > 5
p r.dup.origin
