# Holders the write barrier missed, found by running the suite under
# SPINEL_GC_MINOR=1 SPINEL_GC_VERIFY_GEN=1 SPINEL_GC_STRESS=1 -- every
# collection promotes, so an object filled in AFTER its own allocation is old
# by the time the young value lands in it, and the minor never sees the store:
#
#   * the catch site fills an exception's backtrace and cause; the object can
#     be a re-raised one, a constant instance, or one promoted in between
#   * a runtime constructor allocates a field after the holder (an exception's
#     message, a File::Stat handle's path) with the holder rooted, and rooted
#     is exactly what promotes
#   * a proc body's `s += x` writes a captured cell through the capture
#     struct's field, whose spelling the barrier inserter did not recognise
#   * a block-local captured by a proc inside another proc gets a fresh cell
#     each iteration, stored into the enclosing proc's (old) capture struct
#
# The gc-minor-test leg runs this under the verifier with stress on, so a
# holder that goes unrecorded is reported, not merely risked.
# spinel: gc-minor
ERR = RuntimeError.new("kept")

def catch_site(n)
  out = []
  n.times do |i|
    begin
      raise ERR if i.odd?
      raise ArgumentError, "fresh #{i}"
    rescue => e
      begin
        raise TypeError, "inner #{i}"
      rescue => f
        out << [e.class.name, f.cause.class.name, e.message.length]
      end
    end
  end
  out.last
end

def acc(init, a, b)
  s = init
  f = proc { |x| s += x }
  f.call(a)
  f.call(b)
  s
end

def nested
  made = []
  [1, 2].each do |outer|
    [10, 20].each do |inner|
      seen = []
      seen << (outer * inner)
      made << proc { seen }
    end
  end
  made.map { |pr| pr.call.first }
end

def stats(n)
  path = "/tmp/sp_gc_minor_barrier_#{Process.pid}"
  File.write(path, "x")
  sizes = []
  n.times { sizes << File.stat(path).size }
  File.delete(path)
  sizes.sum
end

def arity_errors(n)
  bad = 0
  n.times do
    begin
      [1, 2].first(1, 2)
    rescue ArgumentError => e
      bad += 1 if e.message.include?("wrong number")
    end
  end
  bad
end

p catch_site(40)
p acc("", "a", "b")
p acc([1], [2], [3])
p nested
p stats(30)
p arity_errors(30)
