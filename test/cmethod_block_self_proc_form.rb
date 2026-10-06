# A block in a class or module method reads self as the class object, also
# when it goes to a method on a receiver of more than one class and is
# compiled as a proc of its own (#7166).
class Shelf
  def initialize(items) = @items = items
  def map(&blk) = @items.map(&blk)
end

module Checker
  def self.labels(list)
    list.map { |e| "#{self.class} #{e}" }
  end
  def self.names(list)
    list.map { |e| "#{self} #{e}" }
  end
end

class Report
  def self.rows(list)
    list.map { |e| [self, e] }
  end
end

p Checker.labels(["a"])
p Checker.labels(Shelf.new(["b"]))
p Checker.names(["a"])
p Checker.names(Shelf.new(["b"]))
p Report.rows([1])
p Report.rows(Shelf.new([2]))
