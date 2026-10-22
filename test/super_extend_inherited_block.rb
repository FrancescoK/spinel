# Repeated extends skip inherited copies when super forwards a block.
class X
  def self.walk
    yield 1
    yield 2
  end
end
module Twice
  def walk
    super { |v| yield v + 10 }
  end
end
class Y < X
  extend Twice
end
class Z < Y
  extend Twice
end
Z.walk { |v| p v }
Y.walk { |v| p v }

# An intervening subclass keeps the same module entry in the ancestry.
module Hooks
  def setup
    super { |v| yield v * 2 }
  end
end
class Base
  def self.setup
    yield 5
  end
end
class Mid < Base
  extend Hooks
end
class Leaf < Mid
end
class Leaf2 < Leaf
  extend Hooks
end
Leaf.setup { |v| p v }
Leaf2.setup { |v| p v }
