# `+s` answers s itself when s is not frozen, so the Array's element is the
# caller's String and an append through the element changes it. The element
# is a copy today (x.size 3, CRuby 153): refused, also when every caller
# passes a frozen literal and `+s` copies in CRuby too.
class Log
  def initialize = (@lines = [])
  def add(s) = (@lines << +s)
  def stamp(i) = (@lines[i] << " ok" * 50)
  attr_reader :lines
end
l = Log.new
x = +"one"
l.add(x)
l.stamp(0)
p x.size, l.lines[0].size
