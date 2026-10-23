# The two String representations refused this program; with one it answers as CRuby.
# A call the C dispatches on the receiver's class (a subclass overrides the method) runs the clone
# of whichever method answers, so the String its block hands back cannot be carried as the
# handle through the splice of the base method: the element is refused.
class Base
  def bc = yield
  def go(s) = [bc { s }]
end
class Sub < Base
  def bc = yield
end
s = +"src"
a = Base.new.go(s)
a[0] << "!"
p a, s
