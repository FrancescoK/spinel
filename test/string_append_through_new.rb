# A String passed to an `initialize` that appends to its parameter: `new`
# hands the method the caller's String, as CRuby does, so the append
# reaches `s` (#6179). It was refused at compile time until `new` shared a
# String by reference.
class Box
  def initialize(s) = (s << "!")
end
s = +"a"
Box.new(s)
p s
