# A program that gives Hash its own merge! keeps it for a Hash literal
# receiver too: here through a module prepended. Each other way of
# binding the name has its own test, since one of them in a program
# keeps every call as written.
module Loud
  def merge!(o) = (puts "prepended merge!"; self)
end
Hash.prepend(Loud)

p({}.merge!({ a: 1 }))
