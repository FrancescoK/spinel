# The same build-up local, where Bag#each keeps what its block answers: the
# append's value, the String itself, is then held by the Bag too, so the
# method's answer is no new String. The call past the plan's list still
# hands on the handle every inspect publishes, so the String keeps one
# identity through the Hash, the Bag and the change in place (#9258).

class Bag
  attr_reader :kept
  def initialize(*a) = @a = a
  def each
    @a.each { |x| @kept = yield x }
    self
  end
end
class K0
  def initialize(items) = @items = items
  def inspect
    out = +"K0("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K1
  def initialize(items) = @items = items
  def inspect
    out = +"K1("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K2
  def initialize(items) = @items = items
  def inspect
    out = +"K2("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K3
  def initialize(items) = @items = items
  def inspect
    out = +"K3("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K4
  def initialize(items) = @items = items
  def inspect
    out = +"K4("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K5
  def initialize(items) = @items = items
  def inspect
    out = +"K5("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K6
  def initialize(items) = @items = items
  def inspect
    out = +"K6("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K7
  def initialize(items) = @items = items
  def inspect
    out = +"K7("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K8
  def initialize(items) = @items = items
  def inspect
    out = +"K8("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K9
  def initialize(items) = @items = items
  def inspect
    out = +"K9("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K10
  def initialize(items) = @items = items
  def inspect
    out = +"K10("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K11
  def initialize(items) = @items = items
  def inspect
    out = +"K11("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K12
  def initialize(items) = @items = items
  def inspect
    out = +"K12("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K13
  def initialize(items) = @items = items
  def inspect
    out = +"K13("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K14
  def initialize(items) = @items = items
  def inspect
    out = +"K14("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K15
  def initialize(items) = @items = items
  def inspect
    out = +"K15("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K16
  def initialize(items) = @items = items
  def inspect
    out = +"K16("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K17
  def initialize(items) = @items = items
  def inspect
    out = +"K17("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K18
  def initialize(items) = @items = items
  def inspect
    out = +"K18("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K19
  def initialize(items) = @items = items
  def inspect
    out = +"K19("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K20
  def initialize(items) = @items = items
  def inspect
    out = +"K20("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K21
  def initialize(items) = @items = items
  def inspect
    out = +"K21("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K22
  def initialize(items) = @items = items
  def inspect
    out = +"K22("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K23
  def initialize(items) = @items = items
  def inspect
    out = +"K23("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K24
  def initialize(items) = @items = items
  def inspect
    out = +"K24("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K25
  def initialize(items) = @items = items
  def inspect
    out = +"K25("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K26
  def initialize(items) = @items = items
  def inspect
    out = +"K26("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K27
  def initialize(items) = @items = items
  def inspect
    out = +"K27("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K28
  def initialize(items) = @items = items
  def inspect
    out = +"K28("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K29
  def initialize(items) = @items = items
  def inspect
    out = +"K29("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K30
  def initialize(items) = @items = items
  def inspect
    out = +"K30("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K31
  def initialize(items) = @items = items
  def inspect
    out = +"K31("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K32
  def initialize(items) = @items = items
  def inspect
    out = +"K32("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K33
  def initialize(items) = @items = items
  def inspect
    out = +"K33("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K34
  def initialize(items) = @items = items
  def inspect
    out = +"K34("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K35
  def initialize(items) = @items = items
  def inspect
    out = +"K35("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K36
  def initialize(items) = @items = items
  def inspect
    out = +"K36("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K37
  def initialize(items) = @items = items
  def inspect
    out = +"K37("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K38
  def initialize(items) = @items = items
  def inspect
    out = +"K38("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K39
  def initialize(items) = @items = items
  def inspect
    out = +"K39("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K40
  def initialize(items) = @items = items
  def inspect
    out = +"K40("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K41
  def initialize(items) = @items = items
  def inspect
    out = +"K41("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K42
  def initialize(items) = @items = items
  def inspect
    out = +"K42("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K43
  def initialize(items) = @items = items
  def inspect
    out = +"K43("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K44
  def initialize(items) = @items = items
  def inspect
    out = +"K44("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K45
  def initialize(items) = @items = items
  def inspect
    out = +"K45("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K46
  def initialize(items) = @items = items
  def inspect
    out = +"K46("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K47
  def initialize(items) = @items = items
  def inspect
    out = +"K47("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K48
  def initialize(items) = @items = items
  def inspect
    out = +"K48("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K49
  def initialize(items) = @items = items
  def inspect
    out = +"K49("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K50
  def initialize(items) = @items = items
  def inspect
    out = +"K50("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K51
  def initialize(items) = @items = items
  def inspect
    out = +"K51("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K52
  def initialize(items) = @items = items
  def inspect
    out = +"K52("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K53
  def initialize(items) = @items = items
  def inspect
    out = +"K53("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K54
  def initialize(items) = @items = items
  def inspect
    out = +"K54("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K55
  def initialize(items) = @items = items
  def inspect
    out = +"K55("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K56
  def initialize(items) = @items = items
  def inspect
    out = +"K56("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K57
  def initialize(items) = @items = items
  def inspect
    out = +"K57("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K58
  def initialize(items) = @items = items
  def inspect
    out = +"K58("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K59
  def initialize(items) = @items = items
  def inspect
    out = +"K59("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K60
  def initialize(items) = @items = items
  def inspect
    out = +"K60("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K61
  def initialize(items) = @items = items
  def inspect
    out = +"K61("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K62
  def initialize(items) = @items = items
  def inspect
    out = +"K62("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K63
  def initialize(items) = @items = items
  def inspect
    out = +"K63("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K64
  def initialize(items) = @items = items
  def inspect
    out = +"K64("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K65
  def initialize(items) = @items = items
  def inspect
    out = +"K65("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K66
  def initialize(items) = @items = items
  def inspect
    out = +"K66("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K67
  def initialize(items) = @items = items
  def inspect
    out = +"K67("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K68
  def initialize(items) = @items = items
  def inspect
    out = +"K68("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
class K69
  def initialize(items) = @items = items
  def inspect
    out = +"K69("
    @items.each { |x| out << x.to_s << "," }
    out << ")"
    out
  end
end
module Util
  def self.lit(x) = x.inspect
end
objs = [K0.new(Bag.new(1, 2)), K1.new([3]), K2.new(Bag.new(1, 2)), K3.new([3]), K4.new(Bag.new(1, 2)), K5.new([3]), K6.new(Bag.new(1, 2)), K7.new([3]), K8.new(Bag.new(1, 2)), K9.new([3]), K10.new(Bag.new(1, 2)), K11.new([3]), K12.new(Bag.new(1, 2)), K13.new([3]), K14.new(Bag.new(1, 2)), K15.new([3]), K16.new(Bag.new(1, 2)), K17.new([3]), K18.new(Bag.new(1, 2)), K19.new([3]), K20.new(Bag.new(1, 2)), K21.new([3]), K22.new(Bag.new(1, 2)), K23.new([3]), K24.new(Bag.new(1, 2)), K25.new([3]), K26.new(Bag.new(1, 2)), K27.new([3]), K28.new(Bag.new(1, 2)), K29.new([3]), K30.new(Bag.new(1, 2)), K31.new([3]), K32.new(Bag.new(1, 2)), K33.new([3]), K34.new(Bag.new(1, 2)), K35.new([3]), K36.new(Bag.new(1, 2)), K37.new([3]), K38.new(Bag.new(1, 2)), K39.new([3]), K40.new(Bag.new(1, 2)), K41.new([3]), K42.new(Bag.new(1, 2)), K43.new([3]), K44.new(Bag.new(1, 2)), K45.new([3]), K46.new(Bag.new(1, 2)), K47.new([3]), K48.new(Bag.new(1, 2)), K49.new([3]), K50.new(Bag.new(1, 2)), K51.new([3]), K52.new(Bag.new(1, 2)), K53.new([3]), K54.new(Bag.new(1, 2)), K55.new([3]), K56.new(Bag.new(1, 2)), K57.new([3]), K58.new(Bag.new(1, 2)), K59.new([3]), K60.new(Bag.new(1, 2)), K61.new([3]), K62.new(Bag.new(1, 2)), K63.new([3]), K64.new(Bag.new(1, 2)), K65.new([3]), K66.new(Bag.new(1, 2)), K67.new([3]), K68.new(Bag.new(1, 2)), K69.new([3])]
o = objs[ARGV.size * 3]
s = Util.lit(o)
t = Util.lit("str")
names = { a: s, b: t }
s << "!"
p names[:a], names[:b], s, Util.lit(objs[1])
b = Bag.new(9)
u = Util.lit(K0.new(b))
u << "?"
p b.kept, b.kept.equal?(u)
