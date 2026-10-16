# A constant written through a path to a class (`Base::LIMIT = 8`) is that
# class's constant, not the top-level one of the same name written after it:
# reads through the class, a subclass, the class's methods and const_get
# see 8, the top-level name sees 1.
module Outer
  class Base
    def get = LIMIT
    def self.lim = LIMIT
  end
end
class Sub < Outer::Base; end
Outer::Base::LIMIT = 8
Outer::Base::NAMES ||= [:a]
LIMIT = 1
NAMES = [:top]
p Outer::Base::LIMIT, Sub::LIMIT, LIMIT, Outer::Base.new.get, Outer::Base.lim
p Outer::Base::NAMES, NAMES, Outer::Base.const_get(:LIMIT)
module Solo; end
Solo::ONLY = 3
p Solo::ONLY
# ... and so is one written through an alias of the class
class Held; def self.cap = CAP; end
HeldAlias = Held
HeldAlias::CAP = 4
NestAlias = Outer::Base
NestAlias::DEPTH ||= 2
CAP = 0
DEPTH = 9
p Held::CAP, HeldAlias::CAP, Held.cap, CAP, Held.const_get(:CAP)
p Outer::Base::DEPTH, NestAlias::DEPTH, DEPTH
# a class's path write is its own, not that of another class of the same leaf
class Leaf; end
module Lhs
  class Leaf; end
end
module Rhs
  Leaf = Lhs::Leaf
end
Lhs::Leaf::SIZE = 5
Leaf::SIZE = 6
Rhs::Leaf::WIDTH = 7
SIZE = 0
WIDTH = 0
p Lhs::Leaf::SIZE, Leaf::SIZE, SIZE, Lhs::Leaf.const_get(:SIZE), Leaf.const_get(:SIZE)
p Lhs::Leaf::WIDTH, Lhs::Leaf.const_get(:WIDTH), WIDTH
