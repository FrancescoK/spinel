# A native receiver cannot grow a field through an Object method's write.
require 'stringio'
class Object
  def mark(v) = (@mark = v)
end
s = StringIO.new("")
p s.mark(1)
