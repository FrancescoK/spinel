# A Queue hands values and slots between threads under its own lock: every
# value pushed is popped once, a full SizedQueue's pushers and an empty
# queue's poppers are all woken when the queue lets them go, and none is
# woken twice or left parked.

def wait_until(what)
  deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 10
  until yield
    raise "#{what} never happened" if Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline
    sleep 0.001
  end
end

# Four producers, four consumers, one queue: every value arrives once.
q = Queue.new
producers = Array.new(4) { |p| Thread.new(p) { |pp| 2000.times { |i| q << pp * 10_000 + i } } }
sums = Array.new(4, 0)
counts = Array.new(4, 0)
consumers = Array.new(4) do |c|
  Thread.new(c) do |cc|
    while (v = q.pop) != :done
      sums[cc] += v
      counts[cc] += 1
    end
  end
end
producers.each(&:join)
4.times { q << :done }
consumers.each(&:join)
expected = (0...4).sum { |p| (0...2000).sum { |i| p * 10_000 + i } }
puts "producers and consumers: #{counts.sum} values, sum #{sums.sum == expected ? "right" : "wrong"}"

# A SizedQueue of two: pushers park on it and each pop lets one through.
sq = SizedQueue.new(2)
pushers = Array.new(6) { |i| Thread.new(i) { |k| sq.push(k) } }
wait_until("four pushers parking") { sq.num_waiting == 4 }
got = []
6.times { got << sq.pop }
pushers.each(&:join)
puts "sized queue: #{got.sort.inspect}, #{sq.num_waiting} waiting"

# More poppers than one batch of a wake, released by close.
cq = Queue.new
poppers = Array.new(100) { Thread.new { cq.pop } }
wait_until("100 poppers parking") { cq.num_waiting == 100 }
cq.close
puts "close: #{poppers.map(&:value).uniq.inspect}"

# Pushers on a full queue are released by clear.
fq = SizedQueue.new(1)
fq << 0
blocked = Array.new(3) { |i| Thread.new(i) { |k| fq.push(k + 1); :pushed } }
wait_until("three pushers parking") { fq.num_waiting == 3 }
fq.clear
taken = []
3.times { taken << fq.pop }
puts "clear: #{blocked.map(&:value).inspect}, then #{taken.sort.inspect}"

# Timed pops racing pushes: each gets a value or times out, and no value is lost.
tq = Queue.new
timed = Array.new(20) { Thread.new { tq.pop(timeout: 0.5) } }
wait_until("20 timed poppers parking") { tq.num_waiting == 20 }
10.times { |i| tq << i }
vals = timed.map(&:value)
puts "timed: #{vals.compact.sort.inspect}, #{vals.count(nil)} timed out, #{tq.size} left"

# A popper killed while parked leaves the others to be served.
kq = Queue.new
a = Thread.new { kq.pop }
b = Thread.new { kq.pop }
wait_until("two poppers parking") { kq.num_waiting == 2 }
b.kill
b.join
kq << :for_a
puts "after a kill: #{a.value.inspect}, #{kq.num_waiting} waiting"
