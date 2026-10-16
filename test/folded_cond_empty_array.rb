# a conditional whose predicate is answered statically (respond_to?, is_a?)
# folds to its live arm; an empty `[]` there takes the conditional's array
# kind, so the ivar it is stored into holds any element later

class L
  def initialize = @a = (respond_to?(:_x, true) ? _x : [])
  def a = @a
end
x = L.new.a
p x
x << "s"
x << 1
p x

class M
  def initialize = @b = (is_a?(Integer) ? 5 : [])
  def b = @b
end
y = M.new.b
y << :t
p y
