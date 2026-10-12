# IO.select over SEVERAL handles from a green thread parks through the
# scheduler like a wait on one does. It was a poll(2) on the OS worker, which
# is a worker lost for the wait -- a server with a thread per connection each
# selecting on two sockets degraded at SPINEL_WORKERS connections -- and a
# worker in a syscall never reaches a safepoint, so every collection waited
# on it, forever when nothing arrived (#4528, ryudoawaru).
require 'socket'

# more selecting threads than workers, each on two pipes; main feeds them one
# at a time and collects in between
n = 12
pairs = Array.new(n) { [IO.pipe, IO.pipe] }
results = Array.new(n) { nil }
threads = Array.new(n) do |i|
  Thread.new do
    (ra, _wa), (rb, _wb) = pairs[i]
    rd, = IO.select([ra, rb])
    got = rd.map { |io| io == ra ? "a" : "b" }.sort.join
    results[i] = got + ":" + rd[0].read(1)
  end
end
sleep 0.1
GC.start
n.times do |i|
  (_ra, wa), (_rb, wb) = pairs[i]
  (i.even? ? wa : wb).write("x")
  GC.start
end
threads.each { |t| t.join(5) }
p results

# a timeout on a set wait expires while the worker stays free
r1, w1 = IO.pipe
r2, w2 = IO.pipe
t0 = Time.now
p IO.select([r1, r2], nil, nil, 0.2)
p((Time.now - t0) >= 0.15)

# the write side of a set: a full pipe becomes writable when it is drained.
# The drainer starts before the fill: a pipe's capacity is 64 KiB only while
# the user is under the kernel's pipe page limit, and a loaded gate runs
# enough programs to push it to one page, where a 64 KiB write with no
# reader yet would block for good.
r3, w3 = IO.pipe
w3.sync = true
drainer = Thread.new { sleep 0.1; r3.read(65536).size }
w3.write("y" * 65536) rescue nil
_rdw, wr = IO.select([r1], [w3])
p wr == [w3]
p drainer.value

# both ready at once answers both
w1.write("1"); w2.write("2")
both, = IO.select([r1, r2])
p both.sort_by { |io| io == r1 ? 0 : 1 } == [r1, r2]

# a thread killed while parked on a set leaves cleanly
r4, w4 = IO.pipe
r5, w5 = IO.pipe
tk = Thread.new { IO.select([r4, r5]) }
sleep 0.1
tk.kill
p tk.join(5).status
w4.write("z")
after, = IO.select([r4, r5], nil, nil, 1)
p after == [r4]
