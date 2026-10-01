# An alias in a reopened builtin -- activesupport's `alias :day :days` in
# Numeric, and the like in Array, Hash and Object -- is called by its
# alias name. The call on a builtin receiver resolved the alias to its
# target and then spelled the alias's name, a function that was never
# emitted, so the C did not compile.
class Numeric
  def days = self * 86400
  alias :day :days
end

class Array
  def second = self[1]
  alias :deuxieme :second
end

class Hash
  def size_twice = size * 2
  alias :twice :size_twice
end

class Object
  def presence_tag = "<#{self}>"
  alias :tag :presence_tag
end

p 1.day, 2.days, 1.5.day
p [1, 2, 3].deuxieme
p({ a: 1 }.twice)
p :sym.tag, nil.tag
