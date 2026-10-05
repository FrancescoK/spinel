class Interp
  def color(x) = (block_given? ? "base#{x}+#{yield}" : "base#{x}")
end
class InterpK < Interp
  def color(x, &block) = "K>" + lambda { super }.call
end
p InterpK.new.color(1) { 9 }
p InterpK.new.color(2)

class ToS
  def color(x) = (block_given? ? "base#{x}+#{yield.to_s}" : "base#{x}")
end
class ToSK < ToS
  def color(x, &block) = "P>" + proc { super }.call
end
p ToSK.new.color(1) { 9 }
p ToSK.new.color(1) { "s" }
p ToSK.new.color(2)

class Tail
  def pick(x) = block_given? ? yield : "none#{x}"
end
class TailK < Tail
  def pick(x, &block) = lambda { super }.call
end
p TailK.new.pick(1) { "blk" }
p TailK.new.pick(2)

class Sum
  def add(x) = block_given? ? x + yield * 2 : x
end
class SumK < Sum
  def add(x, &block) = lambda { super }.call
end
p SumK.new.add(1) { 5 }
p SumK.new.add(3)

class Never
  def color(x) = (block_given? ? "base#{x}+#{yield}" : "base#{x}")
end
class NeverK < Never
  def color(x, &block) = "N>" + lambda { super }.call
end
p NeverK.new.color(4)
