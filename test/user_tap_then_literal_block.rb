# a class that writes its own tap / then: a call with a literal block is
# the class's method, not Kernel's

class Own
  def tap(&blk) = :own_tap
  def then = :own_then
end
class Yields
  def tap
    yield 42
    :yielded
  end
end
p Own.new.tap { }
Own.new.tap { |x| p x }
p Own.new.then { |x| x }
p(Yields.new.tap { |v| p v })
Yields.new.tap { |v| p v + 1 }
p 5.tap { |x| p x }
