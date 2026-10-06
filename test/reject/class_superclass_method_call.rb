# A superclass written as a method call is refused: the call's value is not
# known to the compiler, and it used to be read as no superclass at all, so
# the class silently became a subclass of Object.
class Base
  def hi = "base"
end

def parent = Base

class A < parent
end

p A.new.hi
