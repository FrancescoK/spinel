# A superclass that is an expression rather than a constant (here a rescue
# modifier inside parentheses) is refused: it used to be read as no
# superclass, and the class silently became a subclass of Object.
class Base
  def hi = "base"
end

class A < (Base rescue Object)
end

p A.superclass
