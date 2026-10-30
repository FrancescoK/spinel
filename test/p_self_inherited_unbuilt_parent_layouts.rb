# An exception, an Array subclass or a Hash subclass that has subclasses but no
# object of its own: its objects do not carry their class id, so `p self` in a
# method a subclass inherits asks the default inspect by the class the method is
# defined in. That class keeps its arm because a descendant is built; a Hash
# subclass is boxed as its Hash and never reaches the switch.
class PE < StandardError
  def show
    p self
    puts self.inspect
  end
end

class CE < PE
end

class DE < CE
end

CE.new("m").show
DE.new("n").show

class PA < Array
  def show
    p self
    puts self.inspect
  end
end

class CA < PA
end

CA.new([1]).show

class PH < Hash
  def show
    p self
  end
end

class CH < PH
end

h = CH.new
h[:a] = 1
h.show
