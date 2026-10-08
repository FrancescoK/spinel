# The `case self` form of yield_method_only_in_subclass.rb. It is refused,
# where it used to raise NoMethodError for a GiftOrder.
# spinel: reject-subclass-yield
class Order
  def total
    case self
    when GiftOrder then with_wrapping { |price| price * 2 } + 5
    else 10
    end
  end
end

class GiftOrder < Order
  def with_wrapping = yield(10)
end

p GiftOrder.new.total
p Order.new.total
