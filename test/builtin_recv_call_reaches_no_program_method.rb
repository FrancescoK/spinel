# A class's own + and merge are not reached by an Integer's + or a Hash's
# merge: their bodies are never compiled.
class Vec
  attr_reader :x
  def initialize(x) = @x = x
  def +(o) = eval("Vec.new(@x + o.x)")
  def merge(o) = eval("o")
end

v = Vec.new(1)
i = 0
i = i + v.x
i += 1
h = { a: 1 }.merge({ b: 2 })
p i, h, v.x - 1
