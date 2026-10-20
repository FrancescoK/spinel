# A call on a Class value held in a variable, where some classes answer it
# by a `class << self` accessor and others by a class method of their own:
# each class takes its own arm.
module Labeled
  def lab
    k = self.class
    k.label
  end

  def relabel(v)
    k = self.class
    k.label = v
    k.label
  end
end

class Sym
  include Labeled
  class << self
    attr_accessor :label
  end
end

class Word
  include Labeled
  class << self
    def label = @label

    def label=(v)
      @label = v.upcase
    end
  end
end

class Num
  include Labeled
  def self.label = 42
end

Sym.label = "s"
Word.label = "w"
p Sym.new.lab, Word.new.lab, Num.new.lab
p Sym.new.relabel("t"), Word.new.relabel("x")
def label_of(k) = k.label
p label_of(Sym), label_of(Word), label_of(Num)
def relabel(k, v)
  (k.label = v) && k.label
end
p relabel(Sym, "Sym!"), relabel(Word, "Word!")
p Sym.new.lab.size

# A subclass's own accessor answers ahead of the class method it inherits,
# and a class below it reads and writes its own slot through that accessor.
class Shape
  @@sets = []
  def self.tag = "shape"

  def self.tag=(v)
    @@sets << v
  end

  def self.sets = @@sets

  def tag
    k = self.class
    k.tag
  end

  def retag(v)
    k = self.class
    k.tag = v
    nil
  end
end

class Circle < Shape
  class << self
    attr_accessor :tag
  end
end

class Disc < Circle
end

class Square < Shape
end

Shape.new.retag("s")
Circle.new.retag("c")
Square.new.retag("q")
p Shape.new.tag, Circle.new.tag, Disc.new.tag, Square.new.tag
Disc.new.retag("d")
p Disc.new.tag, Circle.new.tag, Shape.sets

# A class method defined below the accessor's class is ahead of it.
class Badge
  class << self
    attr_accessor :tag
  end

  def tag
    k = self.class
    k.tag
  end
end

class Medal < Badge
  def self.tag = "medal"
end

class Ribbon < Medal
end

class Pin < Badge
end

Badge.tag = "badge"
p Badge.new.tag, Medal.new.tag, Ribbon.new.tag, Pin.new.tag

# A class can declare one half of an accessor and inherit the other: its own
# reader answers ahead of the class method beside the writer it inherits,
# and its own writer ahead of the per-class copy of an inherited `def self.x=`.
class Plate
  def self.tag = "plate"
  class << self
    attr_writer :tag
  end
  def tag
    k = self.class
    k.tag
  end
  def retag(v)
    k = self.class
    k.tag = v
    nil
  end
end
class Cup < Plate
  class << self
    attr_reader :tag
  end
end
class Bowl < Plate
end
Cup.new.retag("cup")
p Plate.new.tag, Cup.new.tag, Bowl.new.tag
class Lid
  class << self
    attr_reader :mark
  end
  def self.mark=(v)
    @mark = "lid:#{v}"
  end
  def mark
    k = self.class
    k.mark
  end
  def remark(v)
    k = self.class
    k.mark = v
    nil
  end
end
class Cap < Lid
  class << self
    attr_writer :mark
  end
end
Cap.new.remark("c")
Lid.new.remark("l")
p Lid.new.mark, Cap.new.mark
p Cup.singleton_methods(false).sort, Cap.singleton_methods(false).sort
p Cup.singleton_methods.sort, Cap.singleton_methods.sort

# A class method defined after the accessor in the same class replaces it,
# also when a subclass gets a copy of the method (it reads a class-level
# ivar) and when no class answers by the accessor at all.
class Seal
  class << self
    attr_accessor :mark
  end

  def self.mark
    "seal:#{@mark}"
  end

  def mark
    k = self.class
    k.mark
  end
end

class Stamp < Seal
end

Seal.mark = "s"
Stamp.mark = "t"
p Seal.new.mark, Stamp.new.mark

class Wax
  class << self
    attr_reader :hue
  end

  def self.hue = "wax"

  def hue
    k = self.class
    k.hue
  end
end
p Wax.new.hue
