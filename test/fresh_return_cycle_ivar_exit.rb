# The two String representations refused this program; with one it answers as CRuby.
# A cycle of inspects whose other way out answers an ivar's String (a leaf
# node's label) is no new String: kept beside a String changed through
# another name and changed through the answer, the program stays refused.
$all = []
b = +"buf"; $all << b; b << "!"
class Node
  def initialize(nx, label) = (@nx = nx; @label = label)
  def inspect = @nx ? @nx.inspect : @label
  def label = @label
end
lab = +"leaf"
leaf = Node.new(nil, lab)
items = [Node.new(ARGV.size > 0 ? 1 : leaf, +"x"), leaf]
r = items.map { |x| x.inspect }
r.each { |e| $all << e; e << "." }
p lab, leaf.label, r, $all
