# A module prepended by a later reopening is not there when an earlier
# statement calls the method: CRuby prints "woof", then "LOUD woof". Spinel
# has one method chain per class, the last; the call picks the class's own
# method or the module's by whether the prepend has run (#9982).
module Loud
  def speak = "LOUD " + super
end
class Dog
  def speak = "woof"
end
d = Dog.new
puts d.speak
class Dog
  prepend Loud
end
puts d.speak
