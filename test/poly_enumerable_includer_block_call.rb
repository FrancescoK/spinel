# A block-taking Enumerable method (select, map, find, sort_by, ...) on a
# value known only at run time, where a class of the program defines a
# method of that name itself: the dispatch made for that class had arms
# for it and for the builtin containers, and an instance of a class that
# answers the name through Enumerable (a Set, a class with an #each that
# includes Enumerable) fell to NoMethodError. It walks its elements as the
# containers do. An object with no Enumerable keeps CRuby's NoMethodError.
require "set"
class Picker
  def initialize(xs) = @xs = xs
  def select(&blk) = [:picker, @xs.select(&blk)]
  def map(&blk) = [:picker_map]
  def reject(&blk) = [:picker_reject]
  def find(&blk) = :picker_find
  def sort_by(&blk) = :picker_sort
  def count(&blk) = -1
  def any?(&blk) = :picker_any
  def sum(&blk) = -2
end
class Bag
  include Enumerable
  def initialize(*xs) = @xs = xs
  def each(&blk) = (@xs.each(&blk); self)
end
class Listy
  def initialize(*xs) = @xs = xs
  def to_a = @xs
end
class Box
  def initialize(v) = @v = v
  def get = @v
end

[Set[3, 1, 2], Bag.new(5, 4), [7, 8], Picker.new([1, 2])].each do |v|
  b = Box.new(v).get
  p b.select { |x| x.odd? }, b.map { |x| x }, b.reject { |x| x.odd? }
  p b.find { |x| x > 1 }, b.sort_by { |x| -x }, b.count { |x| x > 1 }
  p b.any? { |x| x > 4 }, b.sum { |x| x }
end
[Listy.new(1), Object.new].each do |v|
  begin
    Box.new(v).get.select { |x| x }
  rescue NoMethodError => e
    puts e.message.sub(/0x\h+/, "X")
  end
end

# a Set copied into an object and filtered there
class Finder
  def initialize(words:) = @words = words
  def starting(prefix) = @words.select { |w| w.to_s.start_with?(prefix) }.map(&:to_s)
end
def near(target, names)
  names = names.dup
  names.delete(target)
  Finder.new(words: names).starting("a")
end
p near(:ax, Set[:ab, :cd, :ax]), near(:zz, %w[ab cd])
p Finder.new(words: Picker.new(%w[ab cd])).starting("a")

# the elements are what #each yields, not what a #to_a of the class's own
# answers
class Twofold
  include Enumerable
  def each = (yield 1; self)
  def to_a = [2]
end
class Shelf
  def initialize(v) = @v = v
  def get = @v
end
[Twofold.new, Picker.new([1])].each do |v|
  s = Shelf.new(v).get
  p s.map { |x| x }, s.select { |x| x }, s.sum { |x| x }
end
