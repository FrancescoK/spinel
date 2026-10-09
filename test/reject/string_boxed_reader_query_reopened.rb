# spinel: reject-share
# A String read through a reader on a boxed receiver, then asked a method
# the program adds to String that appends to self before the copy: the
# change is the member's own in CRuby, so only String's built-in queries
# keep the copy exception: refused.
class Name
  def initialize(n) = (@n = n)
  def to_s = @n
  def n = @n
end

class String
  def touch? = (self << "!"; true)
end

def tidy(str)
  str = str.to_s
  return "" unless str.touch?
  str = str.dup
  str << "x"
  str
end

name = Name.new(+"a")
p tidy(name), tidy(+"b"), name.n
