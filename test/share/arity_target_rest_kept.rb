# A boxed call's target whose rest parameter takes any count
# answers an Array it keeps, which meets the String's split in the boxed
# Array. A String read out of it is the one a change through another name
# reaches: the kept element itself, or a new String of the split, moved in
# as its handle. (Both were refused: the move boxed each String's text.)
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
y = ARGV.size > 0 ? +"c;d" : PB
tail = y.split(";", 2)[0]
$all << tail
tail << "?"
p head, tail, $kept, $all
