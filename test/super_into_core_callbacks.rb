# A super whose next ancestor is a core class or module calls that builtin
# with the super's arguments, and the builtin calls back the program's methods
# on them: String#+ asks its operand for to_str, Hash#[]= and #[] ask the key
# for hash and eql?, Comparable#between? and #clamp ask <=>.
class Wrap
  def to_str = "wrapped"
end
class MyStr < String
  def +(o) = super
end
puts(MyStr.new("a") + Wrap.new)

class K
  attr_reader :x
  def initialize(x) = @x = x
  def hash = @x.hash
  def eql?(o) = @x == o.x
end
class Reg < Hash
  def []=(k, v)
    super
  end
  def [](k) = super
end
r = Reg.new
r[K.new(1)] = :a
p r[K.new(1)]

class V
  include Comparable
  attr_reader :x
  def initialize(x) = @x = x
  def <=>(o) = @x <=> o.x
  def clamp(a, b) = super
  def between?(a, b) = super
end
puts V.new(5).clamp(V.new(1), V.new(3)).x
puts V.new(2).between?(V.new(1), V.new(3))
