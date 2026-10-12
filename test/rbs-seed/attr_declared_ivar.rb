# spinel: rbs-seed-run
# An attribute's signature seeds the instance variable it declares. Each of
# these was seeded as the instance variable named after the attribute, which
# holds something else, and the program was refused as contradicting it:
# - `attr_accessor self.dflt: String` is the class's attribute (activesupport
#   declares Time.zone_default so); the instance's own @dflt is an Integer
# - `attr_reader parsed (@raw): String` reads @raw; @parsed is an Integer
# - `attr_reader computed (): Integer` has no variable; @computed is a String
class AttrIvarBox
  class << self
    attr_accessor :dflt
  end

  def initialize
    @dflt = 7
    @raw = "r"
    @parsed = 1
    @computed = "c"
  end

  def dflt = @dflt
  def parsed = @raw
  def computed = @computed.size
  def counts = [@parsed, @computed]
end

AttrIvarBox.dflt = "x"
b = AttrIvarBox.new
p AttrIvarBox.dflt, b.dflt, b.parsed, b.computed, b.counts
