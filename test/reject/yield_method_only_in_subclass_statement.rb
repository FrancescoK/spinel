# The statement form of yield_method_only_in_subclass.rb: the call's value is
# not used. It is refused, where the call used to be skipped with no error.
class Order
  def ship
    with_wrapping { |price| puts "wrapped for #{price}" } if is_a?(GiftOrder)
    puts "shipped"
  end
end

class GiftOrder < Order
  def with_wrapping = yield(10)
end

GiftOrder.new.ship
Order.new.ship
