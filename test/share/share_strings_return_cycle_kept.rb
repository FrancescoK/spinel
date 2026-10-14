# A cycle of inspects with a way out that answers a String another name
# holds (an object's String it keeps) answers that String: a change through
# the answer shows through the object.
$all = []
b = +"buf"; $all << b; b << "!"
class Ref
  def initialize(n, raw) = (@name = n; @raw = raw)
  def inspect = @raw ? @raw : @name.inspect
end
class Wrap
  def initialize(s) = @s = s
  def inspect = @s
  def s = @s
end
kept = +"kept"
w = Wrap.new(kept)
items2 = [Ref.new(ARGV.size > 0 ? 1 : w, nil), w]
r2 = items2.map { |x| x.inspect }
r2.each { |e| $all << e; e << "." }
p kept, w.s, r2
p $all
