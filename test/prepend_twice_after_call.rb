# Two later prepends over one method: a call ahead of both reaches the
# class's own method, then the first module's, then the second's, as each
# statement runs. Each copy hands the call on to the method behind it until
# its own prepend has run (#9982). CRuby prints "woof", "WOOF!" and
# "WOOF! WOOF!".
class Dog
  def speak = "woof"
end
module Loud
  def speak = super.upcase + "!"
end
module Echo
  def speak = super + " " + super
end
def talk(d) = d.speak
d = Dog.new
p talk(d)
class Dog
  prepend Loud
end
p talk(d)
class Dog
  prepend Echo
end
p talk(d)
