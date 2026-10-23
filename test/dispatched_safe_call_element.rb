# The two String representations refused this program; with one it answers as CRuby.
# A call the C dispatches on the receiver's class (a subclass overrides the method) runs the clone
# of whichever method answers, so the String its block hands back cannot be carried as the
# handle through the splice of the base method: the element is refused.
class Base
  def bc(&b) = b&.call
  def go(s) = { v: bc { s } }
end
class Sub < Base
  def bc(&b) = +"sub"
end
s = +"src"
h = Base.new.go(s)
h[:v] << "!"
p h, s
