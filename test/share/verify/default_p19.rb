class Object
  def unused_set(v) = (@zz = v)
  def unused_get = @zz
end
class A; def initialize = (@x = 1); def x = @x; end
p A.new.x
p 5.instance_variable_get(:@q)
h = {a: 1}; p h.size
