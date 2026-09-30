# An initialize that only reads its String, or keeps it, takes the plain
# `const char *` parameter, and so does the String its callers hand it,
# beside an initialize that appends to a String of its own: the handle is
# made where an initialize appends (#6179).
class Grow
  def initialize(s) = (s << "!" * 100)
end
class Count
  def initialize(s) = (@n = s.size)
  def n = @n
end
class Name
  def initialize(s) = (@s = s)
  def s = @s
end
buf = +"a"
Grow.new(buf)
line = +"hello"
n = 0
i = 0
while i < 1000
  n += Count.new(line).n + Name.new(line).s.size
  i += 1
end
p n, buf.size
