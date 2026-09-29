# A class variable first assigned in a REOPENED class/module body belongs to
# that class, not to the top level: the body-level write types and declares
# the module's own slot, and the methods read it back.
class Bag
  def initialize(n) = @n = n
  def n = @n
end

module Store
  def self.tag; "store"; end
end

module Store
  @@bag = Bag.new(3)
  @@name = "shelf"
  @@items = []
  @@count = 0
  def self.bag; @@bag; end
  def self.label; @@name; end
  def self.items; @@items; end
  def self.bump; @@count += 1; end
  def self.count; @@count; end
end

Store.items << 1
Store.items << 2
Store.bump
Store.bump
p Store.tag
p Store.bag.n
p Store.label
p Store.items
p Store.count

class Counter
  def hit; @@hits += 1; end
end
class Counter
  @@hits = 10
  def self.hits; @@hits; end
end
Counter.new.hit
p Counter.hits
