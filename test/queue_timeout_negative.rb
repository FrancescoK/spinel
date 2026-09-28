# A negative Queue/SizedQueue timeout is an already-expired deadline, not an
# ArgumentError; a plain Queue#push rejects extra arguments by arity; and the
# value pushed with a timeout survives allocation in the timeout expression.

q = Queue.new
p q.pop(timeout: -1)
q.push(:item)
p q.pop(timeout: -1)

sq = SizedQueue.new(1)
p sq.push(:a, timeout: -1).equal?(sq)
p sq.push(:b, timeout: -1)
p sq.pop(timeout: -1)
p sq.pop(timeout: -0.5)

begin
  q.push(:x, timeout: 1)
rescue ArgumentError => e
  p e.message
end
begin
  q.push(:x, true, timeout: 0)
rescue ArgumentError => e
  p e.message
end

def pad_timeout(n)
  a = []
  n.times { |i| a << ("pad" * 20) + i.to_s }
  a.size * 0.0 + 0.5
end

rq = SizedQueue.new(4)
bad = 0
300.times do |i|
  rq.push("val-" + i.to_s, timeout: pad_timeout(50))
  bad += 1 unless rq.pop == "val-" + i.to_s
end
p bad
