# GC.total_time is the time spent in garbage collection, in nanoseconds:
# an Integer that never decreases. activesupport's instrumentation events
# read it for every event when GC answers it.
t0 = GC.total_time
p t0.is_a?(Integer)
p t0 >= 0
a = []
20000.times { |i| a << "s#{i}" }
GC.start
t1 = GC.total_time
p t1 >= t0
p GC.respond_to?(:total_time)
