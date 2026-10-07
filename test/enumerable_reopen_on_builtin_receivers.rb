# A method a program adds by reopening Enumerable (activesupport's index_by,
# many?, sole, ...) answers for an Array, a Hash and a Range as well as for a
# class that includes the module, with a literal block or a `&:sym`, on a
# receiver known only at run time too; it may take a rest, call a builtin
# Enumerable method or another of its own. A name Array has of its own (sum,
# join) stays Array's.
module Enumerable
  def index_by
    result = {}
    each { |elem| result[yield(elem)] = elem }
    result
  end
  def many?
    cnt = 0
    each { |e| cnt += 1 if block_given? ? yield(e) : true; return true if cnt > 1 }
    false
  end
  def sole
    case count
    when 1 then first
    when 0 then raise "no element"
    else raise "multiple elements"
    end
  end
  def odd_sizes = group_by(&:odd?).transform_values(&:size)
  def excluding(*elements) = reject { |e| elements.include?(e) }
  def without(*elements) = excluding(*elements)
  def sum = :mine
end
class Bag
  include Enumerable
  def initialize(*xs) = @xs = xs
  def each(&b) = @xs.each(&b)
end
p %w[apple banana].index_by(&:size), [3, 1, 2].many?
p [1, 2, 3].index_by { |x| x * 10 }, [1].many?, [1, 2, 3].many?(&:even?), [1, 2, 4].many?(&:even?)
p({ a: 1, b: 2 }.index_by { |k, v| v }, { a: 1 }.many?, { a: 1, b: 2 }.many?)
p (1..3).index_by { |x| -x }, (1..1).many?, (1..5).many? { |x| x > 3 }
p [7].sole, { k: 1 }.sole, (4..4).sole
begin
  [1, 2].sole
rescue => e
  p e.message
end
p [1, 2, 3, 5].odd_sizes, (1..4).odd_sizes
p Bag.new("a", "bb").index_by(&:size), Bag.new(1).many?, Bag.new(2).sole, Bag.new(1, 2).sum
p [1, 2, 3].excluding(2), (1..4).without(1, 3), { a: 1, b: 2 }.excluding([:a, 1])
x = ARGV.size > 5 ? { a: 1 } : [4, 5, 6]
p x.many?, x.index_by { |v| v }, x.without(5)
p [1, 2].sum, %w[a b].join("-")
