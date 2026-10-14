# spinel: not-cruby
# A boxed call's target whose rest parameter takes any count keeps its answer
# in the call's value (an Array it keeps): a change through the element read
# from it stays refused.
$all = []
b = +"buf"; $all << b; b << "!"
$kept = [+"kept"]
module PB
  def self.split(*a) = $kept
end
x = ARGV.size > 0 ? PB : +"a;b"
head = x.split(";", 2)[0]
$all << head
head << "?"
p head, $kept, $all
