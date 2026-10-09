# A `next` in a Mutex#synchronize block answers synchronize's value and
# leaves the block, as in CRuby. It returned nil and left the loop around
# the synchronize, skipping the rest of that iteration (#8205).
lock = Mutex.new
r = lock.synchronize do
  next 5 if lock.locked?
  6
end
p r
p lock.locked?
[1, 2].each do |i|
  lock.synchronize { next if i == 1 }
  puts "after #{i}"
end

v = [1, 2, 3].map do |i|
  lock.synchronize do
    next i * 10 if i.odd?
    i
  end
end
p v

s = lock.synchronize do
  next "early" if v.size == 3
  "late"
end
p s

nested = lock.synchronize do
  inner = Mutex.new.synchronize { next :inner_next }
  next [inner, :outer_next]
end
p nested

[1, 2, 3].each do |i|
  lock.synchronize { break if i == 2 }
  puts "loop #{i}"
end
p lock.locked?

def from_method(lock)
  lock.synchronize do
    return :returned
  end
  :not_here
end
p from_method(lock)
p lock.locked?

begin
  lock.synchronize do
    next if false
    raise "boom"
  end
rescue => e
  p [e.message, lock.locked?]
end
