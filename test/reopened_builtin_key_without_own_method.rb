# A boxed Array whose class the program reopens (with other methods) and a
# Range reopening defining include? itself: `include?` on a value that may
# be either, or a program object, keys the Array to the builtin's own
# include? -- the reopening has none (I18n.available_locales.include?(:en)
# beside activesupport's Array extensions and Range#include?).
class Array
  def second = self[1]
end
class Range
  def include?(v) = v == :any || cover?(v)
end
class Bag
  def initialize(*a) = @a = a
  def include?(x) = @a.include?(x)
end
def pick(n) = n == 0 ? [:en, :ja] : (n == 1 ? Bag.new(:fr) : (n == 2 ? { de: 1 } : (1..3)))
p pick(0).include?(:en), pick(0).include?(:xx), pick(1).include?(:fr), pick(2).include?(:de)
p pick(3).include?(2), pick(3).include?(:any), [1, 2].second
