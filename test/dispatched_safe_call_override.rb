# The two String representations refused this program; with one it answers as CRuby.
# A call the C dispatches on the receiver's class (a subclass overrides the method) runs the clone
# of whichever method answers, so the String its block hands back cannot be carried as the
# handle through the splice of the base method: the element is refused.
class Base
  def bc(x, &b) = b&.call(x)
  def go(s) = { v: bc(1) { |k| s } }
end
class Sub < Base
  def bc(x, &b) = +"sub"
end
s = +"src"
h1 = Base.new.go(s)
h2 = Sub.new.go(s)
h1[:v] << "1"; h2[:v] << "2"
p h1, h2, s
