# A Symbol block argument in parentheses (`&(:to_s)`) or quoted
# (`&:"to_s"`) is the block `&:to_s` is: it was left a block argument no
# block taker read, and `map` raised NoMethodError.
p [1, 2].map(&(:to_s))
p [1, 2].map(&:"to_s")
p [3, 1].sort_by(&(:-@))
p [1, 2].select(&((:odd?)))
class Box
  def initialize = @items = [3, 1, 2]
  def each_item(&blk) = @items.map(&blk)
end
p Box.new.each_item(&(:to_s))
