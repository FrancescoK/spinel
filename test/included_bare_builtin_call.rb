# A bare call of a builtin method (`strip`, `upcase`, `abs`) in a module
# included or prepended into the builtin is the builtin's method on self.
module Tidy
  def tidy = strip.squeeze(" ")
  def tidy_len = tidy.length + extra
  def extra = 1
end
class String
  include Tidy
end
class Note
  include Tidy
  def strip = "  note  x "
end
module Shout
  def upcase = "!" + super
  def squish = strip.split(" ").join(" ")
  def loud = upcase + "?"
end
class String
  prepend Shout
end
module Mag
  def mag = abs * 10
end
class Integer
  prepend Mag
end

p "  a   b  ".tidy
p " x  y ".tidy_len
p Note.new.tidy
p "ab".upcase
p "  a   b  ".squish
p "x".loud
p(-4.mag)
p ["  q  r ", 3][0].tidy
p ["q", "r"].map(&:upcase)
