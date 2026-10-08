# A String read through a reader on a boxed receiver, only queried, and then
# rebound to a copy (`s = s.dup`) before the in-place change: the change
# lands in the copy, so the member keeps its value, as in CRuby. This is
# Shellwords.escape's shape (`str = str.to_s ... str = str.dup; str.gsub!`),
# which any class with `def to_s = @iv` used to make refused. The refused
# neighbours are in test/reject/string_boxed_reader_mutation.rb and
# test/reject/string_boxed_reader_copied_too_late.rb.
class Name
  def initialize(n) = (@n = n)
  def to_s = @n
  def n = @n
end

def escape(str)
  str = str.to_s
  return "''" if str.empty?
  raise ArgumentError, "NUL" if str.index("\0")
  str = str.dup
  str.gsub!(/ /, "_")
  str
end

def tidy(str)
  str = str.to_s
  str = str.dup
  str << "!"
  str
end

name = Name.new(+"a b")
p escape(name), escape(+"c d"), escape(+""), name.n
p tidy(name), tidy(+"x"), name.n

T = Struct.new(:text)
s1 = [T.new(+"value"), 0][0]
t1 = s1.text
t1 = t1.dup
t1 << "!"
p t1, s1.text
