# A String Array or Hash literal a method answers holds a copy of a shared
# String where no name keeps the literal: a call whose value is dropped
# (`w.attributes` as a statement) leaves nothing to see the copy, and the
# program compiles. Where a name keeps it, or its element is read back,
# the literal holds the handle, an --rbs seed's boxed Hash included (#9258)
class Dropped
  def initialize(name) = (@name = name)
  def name = @name
  def attributes
    { "name" => @name }
  end
  def pair = [@name, "x"]
  #: () -> Hash[String, untyped]
  def seeded = { "name" => @name }
end
class Kept
  def initialize(name) = (@name = name)
  def name = @name
  def attributes
    { "name" => @name }
  end
  def pair = [@name, "x"]
  #: () -> Hash[String, untyped]
  def seeded = { "name" => @name }
end
s = +"w"
w = Dropped.new(s)
o = ARGV.empty? ? w.name : 1
o << "!"
w.attributes
w.pair
w.seeded
p s
t = +"k"
k = Kept.new(t)
q = ARGV.empty? ? k.name : 1
a = k.attributes
b = k.seeded
q << "?"
p a, b, a["name"].equal?(t), b["name"].equal?(t)
k.attributes["name"] << "1"
k.seeded["name"] << "2"
k.pair[0] << "3"
p t
