# An index write through a getter on a receiver that may be any of
# several classes widens each candidate class's ivar.

class A
  def initialize = @c = {}
  def cache = @c
  def put(k, v) = @c[k] = v
end
class B
  def initialize = @c = {}
  def cache = @c
  def put(k, v) = @c[k] = v
end
a = A.new; a.put(1, 2)
b = B.new; b.put(3, 4)
[a, b].each { |o| o.cache["x"] = "y" }
p a.cache, b.cache

class RA
  attr_reader :c
  def initialize = @c = {1 => 2}
end
class RB
  attr_reader :c
  def initialize = @c = {3 => 4}
end
[RA.new, RB.new].each { |o| o.c["x"] = "y"; p o.c }

class P
  def initialize = @c = {1 => 2}
  def cache = @c
end
class PA < P; end
class PB < P; end
[PA.new, PB.new].each { |o| o.cache["x"] = "y"; p o.cache }

class TA
  def initialize = @c = {1 => 2}
  def cache = @c
end
class TB
  def initialize = @c = {3 => 4}
  def cache = @c
end
class TC
  def initialize = @c = {5 => 6}
  def cache = @c
end
[TA.new, TB.new, TC.new].each { |o| o.cache["x"] = "y"; p o.cache }

class OA
  def initialize = @c = {1 => 2}
  def cache = @c
end
class OB
  def initialize = @c = {3 => 4}
  def cache = @c
end
[OA.new, OB.new].each { |o| o.cache[:k] ||= 1.5; p o.cache }
xs = [OA.new, OB.new]
r = xs.map { |o| o.cache["s"] = :v }
p r, xs.map(&:cache)

class LA
  def initialize = @c = [1]
  def list = @c
end
class LB
  def initialize = @c = [2]
  def list = @c
end
[LA.new, LB.new].each { |o| o.list << "s"; p o.list }
