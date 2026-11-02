# a builtin arm takes the call (no reopen); the hoisted temp is celled; the callable appends to a caller String
class W
  def initialize(b) = @b = b
  def put(x) = (@b << x.to_s; x)
end
def run(buf)
  [1, 2].each(&W.new(buf).method(:put))
  buf << "!"
  buf
end
s = +"s"
p run(s)
p s
