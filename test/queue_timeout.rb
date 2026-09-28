# Timeout keywords on Queue#pop and SizedQueue#push. The scheduler wait is
# bounded by one deadline, and aliases share the same behavior.

q = Queue.new
p q.pop(timeout: 0).nil?
q.push(:ready)
p q.deq(timeout: 0)

producer = Thread.new do
  sleep 0.01
  q.push(:arrived)
end
p q.shift(timeout: 1)
producer.join

p q.pop(timeout: 0.01).nil?
p q.pop(false, timeout: 0).nil?
begin
  q.pop(true, timeout: 0)
rescue ArgumentError => e
  p e.message
end
begin
  q.pop(timeout: -1)
rescue ArgumentError => e
  p e.message
end
begin
  q.push(:ignored, timeout: nil)
rescue ArgumentError => e
  p e.message
end

sq = SizedQueue.new(1)
sq.push(:first)
p sq.push(:full, timeout: 0).nil?
p sq.pop(timeout: 0)
p !sq.enq(:second, timeout: 0).nil?
sq.<<(:operator, timeout: 0)

consumer = Thread.new do
  sleep 0.01
  sq.shift
end
p !sq.push(:third, timeout: 1).nil?
p consumer.value
p sq.pop
begin
  sq.push(:negative, timeout: -1)
rescue ArgumentError => e
  p e.message
end
sq.<<(:operator, timeout: 0)
p sq.pop

begin
  sq.push(:blocked, true, timeout: 0)
rescue ArgumentError => e
  p e.message
end
