# An ivar of a Fiber or Thread reopening, or of a module only it mixes
# in, lives in the handle's own attribute store (#9384): nil on a fresh one
module Annotation
  def annotate(a)
    @annotation = a
  end
  def annotation
    @annotation
  end
  def bump
    @count ||= 0
    @count += 1
  end
end
module Mark
  attr_accessor :mark
end
Fiber.prepend(Annotation)
Thread.include(Mark)
class Fiber
  def seen
    @seen = (@seen || 0) + 1
  end
end
f = Fiber.new { 1 }
p f.annotation
f.annotate("x")
p f.annotation
p Fiber.new { 2 }.annotation
f.bump
p f.bump
p [f.seen, f.seen]
t = Thread.new { 3 }
t.join
t.mark = :m
p t.mark
p Thread.new { 4 }.tap(&:join).mark
