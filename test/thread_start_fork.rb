# Thread.start and Thread.fork are Thread.new by other names: the
# arguments go to the block, and the thread's value is the block's (webrick
# runs each request in `Thread.start(sock) { |sock| ... }`)
t = Thread.start(2, "x") { |n, s| s * n }
p t.value
p Thread.fork { :forked }.value
q = Queue.new
ts = (1..3).map { |i| Thread.start(i) { |k| q << k * 10 } }
ts.each(&:join)
p 3.times.map { q.pop }.sort
p ::Thread.start { Thread.current.alive? }.value
