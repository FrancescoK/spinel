# Membership survives module inclusion, prepending and reopened modules.
module RegisteredOrder
end
module RegisteredOrder
  include Comparable
  def <=>(other) = 0
end
class IncludedRegisteredOrder
  include RegisteredOrder
end
class PrependedRegisteredOrder
end
class PrependedRegisteredOrder
  prepend RegisteredOrder
end
class DirectPrependedOrder
  prepend Comparable
  def <=>(other) = 0
end
class RegisteredString < String
end
[IncludedRegisteredOrder.new, PrependedRegisteredOrder.new, DirectPrependedOrder.new].each do |x|
  p(x < x)
  p(x <= x)
  p(x == x)
end
p(RegisteredString.new("a") < RegisteredString.new("b"))
# A prepended module sees Comparable added through a late nested reopen.
module LateInnerOrder
end
module LateOuterOrder
  prepend LateInnerOrder
  def <=>(other) = 0
end
class LateRegisteredOrder
  prepend LateOuterOrder
end
module LateInnerOrder
  include Comparable
end
x = LateRegisteredOrder.new
y = LateRegisteredOrder.new
p(x < y)
p(x <= y)
# Repeated includes do not hide the dependency of a later argument.
module RepeatedOrder
end
module FinalOrder
end
class WideRegisteredOrder
  include RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder,
          RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder,
          RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder,
          RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder,
          RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder,
          RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder,
          RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder,
          RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, RepeatedOrder, FinalOrder
  def <=>(other) = 0
end
module FinalOrder
  include Comparable
end
w = WideRegisteredOrder.new
p(w <= w)
