# A checked constant keeps its read at its operand and preserves nil.
class Slot
  def initialize(set)
    @n = 3 if set
  end
  def eq = @n == K
  def n = @n
  def via = n == K
end
K = (puts 'assigned'; 3)
p Slot.new(false).eq
p Slot.new(true).eq
p Slot.new(false).via
p Slot.new(true).via

class FloatSlot
  def initialize(set)
    @n = 3.5 if set
  end
  def eq = @n == F
  def rhs
    puts 'float rhs'
    3.5
  end
  def held = @n == rhs
end
F = (puts 'float assigned'; 3.5)
p FloatSlot.new(false).eq
p FloatSlot.new(true).eq
p FloatSlot.new(false).held
p FloatSlot.new(true).held

class BoxSlot
  def initialize(n)
    @n = n
  end
  def eq = @n == K
end
p BoxSlot.new(nil).eq
p BoxSlot.new(3).eq
p BoxSlot.new(:other).eq

def compare(first, second)
  p first, second
end
compare(Slot.new(false).n, K)
compare(Slot.new(true).n, K)

module BuildTarget
  class Child
    def initialize(xs)
      puts 'initialized'
    end
  end
end
module BuildOuter
  def self.read
    compare([puts('earlier')], BuildOuter::PARENT::Child.new([puts('argument')]))
  rescue NameError => e
    puts e.message
  end
end
BuildOuter.read
module BuildOuter
  PARENT = (puts 'parent assigned'; BuildTarget)
end
# Only the failing arm above prints an object-independent answer.

module Missing
  def self.read
    p(puts('a'), LATE_K)
  rescue NameError => e
    puts e.message
  end
end
Missing.read
module Missing
  LATE_K = (puts 'late assigned'; 4)
end
Missing.read

# Holding before an effectful sibling keeps the optional representation.
class HeldSlot
  def initialize(set)
    @n = 3 if set
  end
  def rhs
    puts 'rhs'
    3
  end
  def eq = @n == rhs
end
p HeldSlot.new(false).eq
p HeldSlot.new(true).eq
