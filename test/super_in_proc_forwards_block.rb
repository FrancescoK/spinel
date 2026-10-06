class Base
  def color(*args) = "base"
end
module A
  def color(*args, &block) = "A>" + lambda { super(*args) }.call
end
module B
  def color(*args, &block) = "B>" + lambda { super(*args) }.call
end
class K < Base
  include A
  include B
end
p K.new.color
p K.new.color(1) { 2 }

class Paint
  def tint(x, &b) = b ? "tint#{x}+#{b.call(x)}" : "tint#{x}"
end
class Lambda < Paint
  def tint(x, &block) = "L>" + lambda { super(x) }.call
end
class Proc2 < Paint
  def tint(x, &block) = "P>" + proc { super(x) }.call
end
class Zsuper < Paint
  def tint(x, &block) = "Z>" + lambda { super }.call
end
class Anon < Paint
  def tint(x, &) = "A>" + lambda { super(x) }.call
end
class Passed < Paint
  def tint(x, &block) = "S>" + lambda { super(x, &block) }.call
end
[Lambda, Proc2, Zsuper, Anon, Passed].each do |k|
  p k.new.tint(3) { |v| v * 10 }
  p k.new.tint(4)
end

class Tail
  def pick(x) = block_given? ? yield : "none#{x}"
end
class TailK < Tail
  def pick(x, &block) = lambda { super(x) }.call
end
p TailK.new.pick(1) { "blk" }
p TailK.new.pick(2)

class Shade
  def tone(x) = (block_given? ? "shade#{x}+#{yield.to_s}" : "shade#{x}")
  def mix(x) = (block_given? ? "mix#{x}+#{yield}" : "mix#{x}")
end
class ShadeK < Shade
  def tone(x, &block) = "T>" + lambda { super(x) }.call
  def mix(x, &block) = "M>" + proc { super(x) }.call
end
p ShadeK.new.tone(1) { 9 }
p ShadeK.new.tone(2)
p ShadeK.new.mix(3) { "s" }
p ShadeK.new.mix(4)
