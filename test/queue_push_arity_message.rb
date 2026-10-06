# Queue#push takes one argument and SizedQueue#push one or two (non_block);
# one TyKind holds both, and a count neither takes was told SizedQueue's
# range (expected 1..2) on a Queue too. The message now reads the
# receiver's own.
q = Queue.new
begin
  q.push
rescue ArgumentError => e
  p e.message
end
begin
  q.push(1, false, 3)
rescue ArgumentError => e
  p e.message
end
begin
  q.push(1, true)
rescue ArgumentError => e
  p e.message
end
begin
  q.enq(1, true)
rescue ArgumentError => e
  p e.message
end
q << 1
q.enq(2)
p q.size
sq = SizedQueue.new(4)
begin
  sq.push
rescue ArgumentError => e
  p e.message
end
begin
  sq.push(1, false, 3)
rescue ArgumentError => e
  p e.message
end
sq.push(5, true)
sq.enq(6, false)
p sq.size
