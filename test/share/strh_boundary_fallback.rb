# spinel: share
# spinel: gc-minor
# An Array of shared Strings keeps the general form where a boundary or a
# holder is one the handle form does not answer (a parameter that is not a
# plain positional one, a block with several parameters, a nested literal, an
# attribute reader or writer, a path constant), and it answers as it always did.
t = +"t"

# optional, rest and keyword parameters
def opt(a = [], s) = (a << s; a)
def kw(a:) = a << +"k"
def rest(*xs) = xs.each { |x| x << "r" }
rows = [t]
o = opt(rows, +"o")
kw(a: rows)
r = rest(+"p", +"q")
p rows, o, r, t

# a block with two parameters takes the Array apart
def twice(a)
  yield a
  yield a
end
twice(rows) { |a, b| a << "x" if a }
p rows

# an Array nested in another, in a Hash, a multiple write
inner = [t, +"u"]
outer = [inner, [+"v"]]
outer[0] << +"w"
h = { k: inner }
h[:k][0] << "!"
first, *others = inner
p inner, outer.size, h, first, others, t

# attribute methods and a path constant
class Attr
  attr_reader :rows
  attr_writer :rows
  def initialize = @rows = [+"b"]
  def add(s) = @rows << s
end
at = Attr.new
at.add(t)
at.rows << +"x"
at.rows = [t, +"y"]
at.rows[0] << "?"
p at.rows, t
class Path
  TBL = [+"k"]
  def self.add(s) = TBL << s
end
Path.add(t)
Path::TBL[0] << "!"
p Path::TBL, t

# a non-String pushed through a method
def push(a, v) = a << v
mixed = [t]
push(mixed, t)
push(mixed, 1)
push(mixed, nil)
p mixed, t
mixed.each { |e| e << "x" if e.is_a?(String) }
p mixed

# an Array handed to a method no static call reaches
def add(a, s) = a << s
dyn = [+"d"]
send(:add, dyn, t)
method(:add).call(dyn, +"m")
dyn.each { |e| e << "." }
p dyn, t

# beside them an Array nothing here touches keeps the handle form
plain = [t, +"o"]
plain << +"p"
plain.each { |e| e << "." }
p plain, t
