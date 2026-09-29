# An instance held in a class variable: the cvar is a file-scope static
# initialized to NULL and marked through its pointer, so the class cannot
# take the inline value-type representation (a small immutable class with
# only initialize-assigned ivars otherwise does).
class Bag
  def initialize(n) = @n = n
  def n = @n
end
module Store
  @@bag = Bag.new(3)
  def self.bag; @@bag; end
  def self.swap(n); @@bag = Bag.new(n); end
end
p Store.bag.n
Store.swap(7)
p Store.bag.n
class Keeper
  @@last = Bag.new(1)
  def self.last = @@last
  def keep(n) = @@last = Bag.new(n)
end
Keeper.new.keep(9)
p Keeper.last.n
