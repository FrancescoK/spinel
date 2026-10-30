# A boxed receiver's utc_offset is answered by Time alone when no class of
# the program that defines it is built, but the call is still typed from
# those classes' returns: an Integer? one or an untyped one. The Time answer
# is put in that slot.
class Zone
  def initialize(o)
    @o = o
  end

  def utc_offset
    @o
  end

  def self.lookup(n)
    Zone.new(n.size > 3 ? nil : n.size)
  end
end

class Clock
  def initialize(o)
    @o = o
  end

  def gmt_offset
    @o
  end

  def self.lookup(n)
    Clock.new(n.size > 3 ? "x" : n.size)
  end
end

def zulu(t)
  t.utc_offset == 0 ? "Z" : "+"
end

def gmt(t)
  t.gmt_offset == 0 ? "Z" : "+"
end

p zulu(ARGV.size > 5 ? "x" : Time.at(0).utc)
p gmt(ARGV.size > 5 ? "x" : Time.at(0).utc)
p Zone.name
p Clock.name
