# A lone `*rest` block parameter on the builtin predicate / fold lowerings
# (any?, all?, none?, one?, count, sum, find_index, take_while, ...) binds
# what the iteration yields, as one array: the element for an Array, the
# [key, value] pair for a Hash -- `|*rest|` is `|e| rest = [e]` there. It
# used to stop the build ("not supported by the lowering"); activesupport's
# Enumerable#many? forwards `any? do |*args| ... yield(*args)`.
p [3, 4].any? { |*a| a.first == 4 }, [3, 4].all? { |*a| a.size == 1 }
p [3, 4].none? { |*a| a == [5] }, [3, 4, 4].one? { |*a| a == [3] }
p [1, 2, 3].count { |*a| a[0].odd? }, [1, 2, 3].sum { |*a| a[0] * 10 }
p [5, 6, 7].find_index { |*a| a == [6] }, [1, 2, 9, 3].take_while { |*a| a[0] < 5 }
h = { a: 1, b: 2 }
p h.any? { |*kv| kv == [[:b, 2]] }, h.all? { |*kv| kv[0][1] > 0 }, h.count { |*kv| kv[0][1] > 1 }
class Bag
  include Enumerable
  def initialize(*items) = @items = items
  def each(&b) = @items.each(&b)
  def many?
    cnt = 0
    if block_given?
      any? do |*args|
        cnt += 1 if yield(*args)
        cnt > 1
      end
    else
      any? { (cnt += 1) > 1 }
    end
  end
end
p Bag.new(1, 2, 3).many?, Bag.new(1).many?, Bag.new.many?
p Bag.new(1, 2, 3).many? { |n| n > 1 }, Bag.new(1, 2, 3).many? { |n| n > 2 }
