# A user respond_to? that answers its own names and defers to `super`: the
# super is Object#respond_to? for this object, so the class's real methods
# and the builtin surface still answer (activesupport's proxies and
# duck-typing helpers use this shape).
class Dyn
  def respond_to?(m, include_all = false) = m == :magic || super
  def real = 1
  private def hidden = 2
end
d = Dyn.new
p d.respond_to?(:magic), d.respond_to?(:real), d.respond_to?(:other)
p d.respond_to?(:to_s), d.respond_to?(:hidden), d.respond_to?(:hidden, true)

class Sub < Dyn
  def respond_to?(m, include_all = false) = m == :extra || super
  def own = 3
end
s = Sub.new
p s.respond_to?(:extra), s.respond_to?(:magic), s.respond_to?(:own), s.respond_to?(:nope)

names = [:magic, :real, :zzz]
p names.map { |n| d.respond_to?(n) }
