# Singleton methods on an Object.new in a program that reopens Object (as
# minitest's mock.rb does): the object reaches both its own methods and the
# reopening's, and still answers as an Object.
class Object
  def helper = "helper"
end
pattern = Object.new
def pattern.=~(x) = x == 5
def pattern.inspect = "[pattern]"
p pattern =~ 5, pattern =~ 4
p pattern.helper
p pattern
p pattern.class, pattern.instance_of?(Object), pattern.is_a?(Object), Object === pattern
p pattern.respond_to?(:=~), Object.new.respond_to?(:=~)
