# A worker whose own queue never empties still gives the global queue and its
# readiness set their turns.
#
# With one helper worker (set before the first thread starts; CRuby ignores
# it), two threads that never block are spawned before the helper is up, so
# both wait on the global queue. The helper takes one, and must still take
# the other: the first keeps the helper's own queue busy for good. Then a
# thread pinned behind them waits to read a pipe, and its readiness event
# has to be taken from that busy worker's set while both still spin.
ENV["SPINEL_WORKERS"] = "1"

def wait_for(what)
  deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 10
  until yield
    raise "#{what} never happened" if Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline
    sleep 0.001
  end
end

stop = false
started = [false, false]
hogs = (0...2).map do |i|
  Thread.new(i) do |k|
    started[k] = true
    n = 0
    n += 1 until stop
    n > 0
  end
end
wait_for("both spinning threads running") { started.all? }
puts "both spinning threads run"

r, w = IO.pipe
reader = Thread.new { r.gets }
wait_for("the reader parking") { reader.status == "sleep" }
w.puts "ready"
wait_for("the reader waking") { !reader.alive? }
puts "the reader got #{reader.value.inspect}"
stop = true
p hogs.map(&:value)
