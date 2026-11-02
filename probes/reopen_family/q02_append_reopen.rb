# the reopen's proc form takes the call; the hoisted temp is celled; the callable appends to a caller String
class Array
  def each_with_object(m) = (each { |x| yield(x, m) }; m)
end
class W
  def initialize(b) = @b = b
  def keep(x, m) = (@b << x.to_s; m << x; m)
end
def run(buf)
  r = [1, 2].each_with_object([], &W.new(buf).method(:keep))
  buf << "!"
  [r, buf]
end
s = +"s"
p run(s)
p s
