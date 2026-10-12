# Calls on a receiver that may be nil in a hot loop: each tests the
# receiver (the call plan's nil target, #7444), and the fact narrows the
# reads a loop guard or an earlier call already proved.
class Node
  attr_reader :v, :nxt
  def initialize(v, nxt) = (@v = v; @nxt = nxt)
end
def build(n)
  head = nil
  n.times { |i| head = Node.new(i, head) }
  head
end
def pick(head, k) = k > 0 ? head : nil
head = build(1000)
t = 0
40_000.times do |k|
  cur = pick(head, k + 1)
  while cur
    t += cur.v
    cur = cur.nxt
  end
  n = pick(head, k)
  t += n.v if n
end
p t
