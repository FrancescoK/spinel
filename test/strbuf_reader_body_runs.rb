# A reader whose last statement reads the String ivar it hands out still runs
# the statements before it when a caller mutates the String through it
class Counted
  attr_reader :reads
  def initialize(s) = (@s = s; @reads = 0)
  def s; @reads += 1; @s; end
  def shout; s.upcase!; end
end

k = Counted.new("abc".dup)
k.s.upcase!
p k.reads
k.s << "d"
p k.s, k.reads
w = k.s.downcase!
p w, k.reads
k.shout
p k.s, k.reads
k.s[0] = "Z"
p k.s, k.reads
