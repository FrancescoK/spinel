# `p` of an object whose class others inherit from asks the default inspect for
# the class the object carries only where its objects start with their class id.
# A Hash or Array subclass is the builtin container, and an exception starts with
# its class name, so they are rendered as their own kind, in a method they
# inherit (`p self`) and held in a local (`p h`).
class H < Hash
end

class G < H
end

h = H.new
h[:a] = 1
p h
g = G.new
g[:b] = 2
p g

class PH < Hash
  def show
    p self
  end
end

class CH < PH
end

ch = CH.new
ch[:c] = 3
ch.show
PH.new.show

class PA < Array
  def show
    p self
    puts self.inspect
  end
end

class CA < PA
end

CA.new([1]).show
PA.new([2]).show

class PE < StandardError
  def initialize(m = "pe")
    super
    @k = 1
  end

  def show
    p self
    puts self.inspect
  end
end

class CE < PE
end

class DE < PE
end

CE.new.show
DE.new("d").show
PE.new.show

class PS < String
  def show
    p self
  end
end

class CS < PS
end

CS.new("x").show
PS.new("y").show
