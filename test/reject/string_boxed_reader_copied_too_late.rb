# spinel: reject-share
# A String read through a reader on a boxed receiver is changed before the
# local is rebound to a copy, so the change is the member's own in CRuby
# and would be lost to a copy here: refused. Rebound before the change, it
# compiles (test/string_reader_rebound_to_copy.rb).
class Name
  def initialize(n) = (@n = n)
  def to_s = @n
  def n = @n
end

def tidy(str)
  str = str.to_s
  str << "!"
  str = str.dup
  str
end

name = Name.new(+"a b")
p tidy(name), tidy(+"x"), name.n
