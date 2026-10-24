# respond_to? on a builtin value answers from that value's class: a method
# the program adds to Integer (directly or through a module) is not a
# String's, and a predicate name no class defines is nobody's.
module Flag
  def flag? = true
  def flagged = 1
end
class Integer
  include Flag
  def lbl = "i"
end
module Shouty
  def shout = upcase + "!"
end
class String
  include Shouty
end

p "s".respond_to?(:flag?)
p "s".respond_to?(:flagged)
p "s".respond_to?(:lbl)
p "s".respond_to?(:zork?)
p 1.respond_to?(:zork?)
p 1.5.respond_to?(:lbl)
p :x.respond_to?(:flag?)
p nil.respond_to?(:flag?)
p [1].respond_to?(:flagged)
p({a: 1}.respond_to?(:flag?))
p 3.respond_to?(:flag?)
p 3.respond_to?(:lbl)
p "s".respond_to?(:shout)
p "s".respond_to?(:empty?)
p 3.respond_to?(:even?)
s = "word"
p s.respond_to?(:flag?)
x = ["s", 1][0]
p x.respond_to?(:flag?)
p 3.flag?
