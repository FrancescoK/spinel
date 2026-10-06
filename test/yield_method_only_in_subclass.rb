# A parent method that calls, with a block, a yielding method only a
# subclass defines is refused (test/reject/yield_method_only_in_subclass.rb).
# These programs are near that shape and compile.

# the parent defines the method, and the subclass overrides it
class Order
  def total
    if is_a?(GiftOrder)
      with_wrapping { |price| price * 2 } + 5
    else
      10
    end
  end

  def note
    v = "none"
    v = with_wrapping { |price| price * 2 } if is_a?(GiftOrder)
    v
  end

  def with_wrapping = raise(NotImplementedError)
end

class GiftOrder < Order
  def with_wrapping = yield(10)
end

p GiftOrder.new.total
p Order.new.total
p GiftOrder.new.note
p Order.new.note

# a generated Struct iterator stays as it was for a Struct subclass
Pair = Struct.new(:a, :b) do
  def second = each_with_index { |v, i| break v if i == 1 }
end

class NamedPair < Pair
end

p Pair.new(1, 2).second
p NamedPair.new(3, 4).second

# a Kernel method with a block stays Kernel's, though a subclass defines one
class Runner
  def run
    loop do |x|
      p x
      break
    end
    catch { |tag| throw tag, 7 }
  end
end

class FastRunner < Runner
  def loop = yield(10)
  def catch = yield(:a)
end

p Runner.new.run
