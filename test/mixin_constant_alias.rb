# A module named through a constant that aliases it (`L = Logged`) is mixed
# in as the module itself: `extend L` and a `prepend L` that becomes an
# extend (`class << self`, `singleton_class.prepend`) used to drop it.
module Logged
  def call(x) = super(x) + 1
end
module ClassSide
  def kind = "class side"
end
module Tag
  def tag = "<#{self}>"
end
L = Logged
C = ClassSide
C2 = C
module NS
  Helper = Tag
end

class Svc
  class << self
    prepend L
    def call(x) = x * 10
  end
end
class Svc2
  singleton_class.prepend L
  def self.call(x) = x * 100
end
class Svc3
  def self.call(x) = x * 1000
end
Svc3.singleton_class.prepend(L)
class Box
  prepend L
  def call(x) = x * 7
end
class Kinded
  extend C
end
class Kinded2
  extend C2
end
class Holder
  extend NS::Helper
end
class Word
  include NS::Helper
  def to_s = "word"
end

p Svc.call(5)
p Svc2.call(5)
p Svc3.call(5)
p Box.new.call(1)
p Kinded.kind
p Kinded2.kind
p Holder.tag
p Word.new.tag
p Box.ancestors.first(2)
