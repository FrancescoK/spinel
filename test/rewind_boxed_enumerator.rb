# rewind on a value read back out of a container: an Enumerator rewinds and
# answers itself, a stream answers 0. It took the stream arm alone, and an
# Enumerator raised NoMethodError.
require "stringio"
e = [(1..3).each, 1][0]
p e.next
p e.next
e.rewind
p e.next
f = [[4, 5].each, nil].first
p f.next
r = f.rewind
p r.equal?(f), f.next, f.peek
s = [StringIO.new("ab"), 1][0]
p s.read
p s.rewind
p s.read
class Res
  def rewind = :own
end
[Res.new, [7].each, StringIO.new("q")].each { |x| p x.rewind.class }
