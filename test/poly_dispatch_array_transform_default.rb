# A poly receiver whose method name a user class ALSO defines dispatches
# through the user-class arms; an Array reaching that switch has no arm and
# raised NoMethodError for flatten / compact / uniq, which Array answers.
# The default arm now serves an Array through the builtin transform (and
# still raises for anything else, as it should).
# (every Bag holds a mixed array, so @items is one array kind)
class Bag
  def initialize(items) = @items = items
  def flatten = @items.flatten
  def compact = @items.compact
  def uniq = @items.uniq
  def size = @items.size
end
def flat(x) = x.flatten
p flat([[1, 2], [3, [4]]]), flat(Bag.new([[5], 6])), flat([7])
def squash(x) = x.compact
p squash([1, nil, 2]), squash(Bag.new([nil, 3, "z"])), squash([nil])
def once(x) = x.uniq
p once([1, 1, 2]), once(Bag.new([4, 4, "x"])), once(["a", "a"])
# the result feeding a poly slot, as activesupport's `words.flatten.map` does
def names(x) = x.flatten.map { |w| w.to_s.upcase }
p names([["equipment", "information"], "rice"]), names(Bag.new([["a"], "b"]))
begin
  flat("not an array")
rescue NoMethodError => e
  puts "NoMethodError: #{e.message[0, 26]}"
end
