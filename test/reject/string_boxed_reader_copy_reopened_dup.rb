# spinel: reject-share
# A String read through a reader on a boxed receiver, rebound with a `dup`
# the program redefines to answer self: the change after it is the
# member's own in CRuby, so the copy exception does not apply: refused
# (test/string_reader_rebound_to_copy.rb is the built-in dup's case).
class Name
  def initialize(n) = (@n = n)
  def to_s = @n
  def n = @n
end

class String
  def dup = self
end

def tidy(str)
  str = str.to_s
  str = str.dup
  str << "x"
  str
end

name = Name.new(+"a")
p tidy(name), tidy(+"b"), name.n
