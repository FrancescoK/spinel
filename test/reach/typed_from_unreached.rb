# A class only an unreached method builds still types the code that is
# reached: Frag.matches? runs for the call on an unknown receiver once Frag
# is named, and its parameter is the Sel that Frag.parse and Z.go hand it,
# though neither runs. The direct call it makes of Sel#kind is written, and
# Sel's instance side with it (#10592).
# present: sp_Sel_kind
class Sel
  def initialize(k)
    @k = k
  end

  def kind
    @k
  end
end

class Frag
  def self.parse(t)
    Sel.new(t)
  end

  def self.matches?(m)
    m.kind == "all"
  end
end

class Z
  def self.go
    Frag.matches?(Sel.new("all"))
  end
end

class Entry
  def matches?(name)
    name == "x"
  end
end

list = [Entry.new]
p list[0].matches?("x")
p Frag.name
