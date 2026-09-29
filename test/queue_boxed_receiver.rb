# A Queue taken out of an Array or held in an ivar beside other values
# still answers as a Queue: size, pop, close and the rest.
q = Queue.new
sq = SizedQueue.new(2)
b = [q, 1, "x"][0]
s = [sq, 1][0]

b.push(1)
b << 2
b.enq(3)
p [b.size, b.length, b.empty?]
p [b.pop, b.shift, b.deq]
p [b.size, b.empty?, b.num_waiting, b.closed?]
b.push(9)
b.clear
p b.size
s.push(:a)
p [s.max, s.size]
b.close
p b.closed?

# a user class owning the same names doesn't take them from the queue
class Stack
  def initialize = @a = []
  def size = @a.size
  def pop = @a.pop
  def push(x) = (@a << x; self)
  def closed? = false
  def num_waiting = 99
end
items = [Queue.new, Stack.new]
items.each { |o| o.push(5) }
p items.map(&:size)
p items.map(&:num_waiting)
p items.map(&:closed?)
p items.map(&:pop)

# producer and consumer sharing a queue held in an ivar
class Pipe
  def initialize = @q = [Queue.new, nil][0]
  def put(x) = @q << x
  def take = @q.pop
  def waiting = @q.num_waiting
end
pipe = Pipe.new
consumer = Thread.new { 3.times.map { pipe.take } }
200.times { break if pipe.waiting == 1; sleep 0.01 }
p pipe.waiting
3.times { |i| pipe.put(i * 10) }
p consumer.value
