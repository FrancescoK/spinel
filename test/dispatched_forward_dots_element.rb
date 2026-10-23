# The two String representations refused this program; with one it answers as CRuby.
# A call the C dispatches on the receiver's class (a subclass overrides the method) runs the clone
# of whichever method answers, so the String its block hands back cannot be carried as the
# handle through the splice of the base method: the element is refused.
class Base
  def y0 = yield
  def bc(...) = y0(...)
  def go(s) = [bc { s }]
end
class Sub < Base
  def bc(...) = y0(...)
end
s = +"src"
a = Sub.new.go(s)
a[0] << "!"
p a, s
