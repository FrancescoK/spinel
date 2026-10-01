# close on a Queue held in a boxed slot answers the queue, as a typed one
# does; an IO or Dir in the same slot still answers nil.

q = Queue.new
b = [q, 1][0]
p b.close.equal?(q)
p b.closed?

sq = SizedQueue.new(2)
p [sq, 1][0].close.equal?(sq)

r, w = IO.pipe
bw = [w, 1][0]
p bw.close
p bw.closed?
r.close
p [Dir.new("."), 1][0].close
