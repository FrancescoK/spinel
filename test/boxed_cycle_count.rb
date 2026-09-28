# cycle(n) without a block on an Array, a Hash, a Range or an Enumerator
# read out of a container answers an Enumerator over its items repeated n
# times, as on a typed receiver.
a = [[1, 2, 4], 0][0]
e = a.cycle(2)
p e.class
p e.to_a
p e.first(4)
p a.cycle(0).to_a
p [(1..3), 0][0].cycle(2).to_a
p [("a".."b"), 0][0].cycle(2).to_a
p [{ k: 1 }, 0][0].cycle(2).to_a
p [[1, 2].each, 0][0].cycle(2).map { |v| v * 10 }
n = [3, "s"][0]
p a.cycle(n).to_a.size
# a class of the program's own with a cycle(n) keeps it, and an Array in
# the same slot still answers
class Wheel
  def cycle(n) = "wheel #{n}"
end
p [Wheel.new, 0][0].cycle(3)
p [[5, 6], Wheel.new][0].cycle(2).to_a
# the receiver a method answers is held while the count allocates
def fresh(i) = [[i, "s"], 0][0]
acc = []
200.times { |i| acc << fresh(i).cycle([i, 2].size).to_a }
p [acc.size, acc[199]]
p (["str", 0][0].cycle(2) rescue $!.message)
p ([nil, 0][0].cycle(2) rescue $!.message)
