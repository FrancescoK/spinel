# spinel: share
# spinel: gc-minor
# `@s&.to_s` where @s is a box: it also holds nil in another instance. The
# fresh String handed to the constructor is the handle the box holds, so
# the answer, changed in place, is the String the reader answers too.
class Box
  def initialize(s) = @s = s
  def text = @s&.to_s
  attr_reader :s
end
bx = Box.new(+"fresh")
r = bx.text
r << "!"
p bx.s, r
p Box.new(nil).text
