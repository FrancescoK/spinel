# A module mixed into one builtin class runs its methods with that builtin
# value as self, as a reopening's methods do: a bare call is the value's
# own method (`upcase` is self.upcase), and the module's own methods stay
# its own.
module Shout
  def shout = upcase + "!"
  def twice = shout * 2
end
class String
  include Shout
end
p "abc".shout, "ab".twice

module Total
  def total = sum + size
end
class Array
  include Total
end
p [1, 2, 3].total

module Keys
  def key_list = keys.map(&:to_s).join(",")
end
class Hash
  prepend Keys
end
p({ a: 1, b: 2 }.key_list)

module Half
  def half = self / 2
  def halves = [half, fdiv(2), abs]
end
class Integer
  include Half
end
p 9.halves

# a method the class's own reopening defines is self's too
class String
  def loud = upcase
end
module Louder
  def louder = loud + "!!"
end
class String
  include Louder
end
p "hey".louder
