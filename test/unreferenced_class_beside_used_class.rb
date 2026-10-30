# A class nothing builds is left out of the per-class object switches, and
# the classes that are built keep their arms: a used class renders by its
# own inspect, to_s and default walk (p, puts, interpolation, inside an
# Array and a Hash, and boxed beside an Integer), an instance of a subclass
# of a class nothing builds renders by the inherited method, and an object
# given a singleton method renders the same before and after the method.
class Dead
  def initialize
    @d = 1
  end

  def to_s
    "dead"
  end
end

module DeadModule
  def to_s
    "module #{self.class}"
  end
end

class Plain
  def initialize
    @n = 1
    @s = "two"
  end
end

class Shown
  def initialize(v)
    @v = v
  end

  def to_s
    "Shown(#{@v})"
  end

  def inspect
    "#<Shown #{@v}>"
  end
end

class Parent
  def initialize
    @p = :p
  end

  def to_s
    "parent says #{self.class}"
  end

  def inspect
    "#<#{self.class} inspected>"
  end

  def to_int
    4
  end
end

class Child < Parent
end

class Single
  def initialize
    @x = 1
  end

  def show
    puts [self, 1].inspect.gsub(/0x\h+/, "XX")
  end
end

class SingleKid < Single
end

def plain(o)
  o.inspect.gsub(/0x\h+/, "XX")
end

pl = Plain.new
puts plain(pl)
puts plain([pl, 1])
puts plain({ k: pl })
puts "#{pl}".gsub(/0x\h+/, "XX")
sh = Shown.new(7)
p sh
puts sh
puts "#{sh}"
p [sh, 2]
p({ sh => sh })
ch = Child.new
p ch
puts ch
puts "#{ch}"
p [ch, 3]
puts [10, 20, 30, 40, 50][ch]
s = Single.new
sk = SingleKid.new
s.show
sk.show
def s.extra
  :extra
end
s.show
puts s.extra
