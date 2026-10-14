class G
  attr_reader :captures
  def initialize(captures = initial_captures)
    @captures = captures
  end
  def capture(color) = @captures[color] += 1
  def initial_captures
    {:black => 0, :white => 0}
  end
end
g = G.new
g.capture(:black)
g.capture([:white, "w"][ARGV.size])
p g.captures
p g.initial_captures
h = G.new({:black => 5}).capture(:black)
p h

class M
  attr_reader :c
  def initialize(c = {1 => 2}) = (@c = c)
  def add(k) = (@c[k] = 3)
end
m = M.new; m.add("x"); p m.c

class Q
  def self.zero = {x: 1}
  attr_reader :c
  def initialize(c = Q.zero) = (@c = c)
  def add(k) = (@c[k] = 2)
end
q = Q.new; q.add("y"); p q.c
p Q.zero
class Base
  attr_reader :c
  def initialize(c = start) = (@c = c)
  def start = {a: 1}
  def add(k) = (@c[k] = 2)
end
class Sub < Base
  def start = {b: 2}
end
s = Sub.new; s.add("q"); p s.c
