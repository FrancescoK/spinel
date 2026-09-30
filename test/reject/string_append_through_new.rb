# A String passed to an `initialize` that appends to its parameter: `new`
# hands the method a copy, so the append would not reach `s` (CRuby prints
# "a!"). Refused at compile time until `new` shares a String by reference,
# as a proc, a lambda and a Method do (#6179).
class Box
  def initialize(s) = (s << "!")
end
s = +"a"
Box.new(s)
p s
