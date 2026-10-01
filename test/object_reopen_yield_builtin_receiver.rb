# A yielding method the program adds to Object reaches every receiver: a
# builtin one (Integer, String, Float, Symbol, Array, Hash, Range, nil) with
# its block, and any receiver without one, where block_given? is false and a
# yield raises LocalJumpError.
class Object
  def wrap = yield(self)
  def twice(n) = yield(n) + yield(n + 1)
  def maybe = block_given? ? yield(self) : 41
end

5.wrap { |m| p m }
p "s".wrap { |m| m + "!" }
p 1.5.wrap { |m| m * 2 }
p :sym.wrap { |m| m.to_s }
p [1, 2].wrap { |a| a.sum }
p({a: 1}.wrap { |h| h.keys })
p (1..3).wrap { |r| r.to_a }
p nil.wrap { |m| m.inspect }
p 3.twice(10) { |v| v * 2 }
x = 7.wrap { |m| m + 1 }
p x + 1

class Foo; end
p((5.wrap rescue $!.class))
p((Foo.new.wrap rescue $!.class))
p 5.maybe + 1
p "s".maybe
p Foo.new.maybe
p 5.maybe { |m| m * 3 }
p(Foo.new.maybe { |m| m.class })
