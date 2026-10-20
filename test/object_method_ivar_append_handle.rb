# A method of Object that changes an instance variable of its receiver in
# place (`@x << s` in `class Object`, whose self is any class): the
# String the receiver's slot keeps changes, through the box its `@x` reads
# as. The read was bound as a String temp and used as the handle, and the
# C did not compile (#9258).
class Object
  def appx(s) = (@x << s)
  def addx(s)
    @x.concat(s, "!")
    nil
  end
end
class A
  def initialize = (@x = +"init")
end
class B
  def initialize = (@x = +"bee")
  def x = @x
end
a = A.new
a.appx("Z")
p a.instance_variable_get(:@x)
b = B.new
r = b.appx("Q")
p r, b.x
b.addx("W")
p b.x
y = b.x
b.appx("V")
p y
