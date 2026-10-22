# A module prepended by a later reopening is not there when an earlier
# statement calls the method: CRuby prints "woof", then "LOUD woof". Spinel
# has one method chain per class, the last, so the first call would print
# "LOUD woof" too; refused, not answered wrongly.
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
