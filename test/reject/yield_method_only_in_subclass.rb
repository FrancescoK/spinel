# An Order method calls, with a block, a yielding method that only a
# subclass defines. A yielding method is inlined at its call sites, and the
# call in Order has no method of its own class to inline. The program is
# refused, where its C used to fail to compile. Defining the method in Order
# (as `raise NotImplementedError`) makes it compile
# (test/yield_method_only_in_subclass.rb).
class Order
  def total
    if is_a?(GiftOrder)
      with_wrapping { |price| price * 2 } + 5
    else
      10
    end
  end
end

class GiftOrder < Order
  def with_wrapping = yield(10)
end

p GiftOrder.new.total
p Order.new.total
