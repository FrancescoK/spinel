# The two String representations refused this program; with one it answers as CRuby.
# A call the C dispatches on the receiver's class (a subclass overrides the method) runs the clone
# of whichever method answers, so the String its block hands back cannot be carried as the
# handle through the splice of the base method: the element is refused.
class Base
  def bc(x, &b) = b.call(x)
  def go(s) = [bc(1) { |k| s }]
end
class Sub < Base
  def bc(x, &b) = b.call(x + 1)
end
s = +"src"
a1 = Base.new.go(s)
a2 = Sub.new.go(s)
a1[0] << "1"; a2[0] << "2"
p a1, a2, s, a1[0].equal?(a2[0])
