# Thread#raise given the exception class as a value -- a parameter, a
# local -- raises that class in the target thread, as with the constant
# written out (the timeout gem's watcher raises the class it was handed).
class Slow < StandardError; end

def watch(target, klass, message, sec)
  Thread.new do
    sleep sec
    target.raise(klass, message)
  end
end

t = Thread.new do
  watch(Thread.current, ArgumentError, "too slow", 0.05)
  sleep 1
  :late
rescue ArgumentError => e
  [e.class, e.message]
end
p t.value

t = Thread.new do
  k = Slow
  me = Thread.current
  Thread.new { sleep 0.05; me.raise(k, "mine") }
  sleep 1
rescue Slow => e
  [e.class, e.message]
end
p t.value

# a value that may be a class or nil (`klass || Default`), and a message
# given in its place
def watch_maybe(target, klass, sec) = Thread.new { sleep sec; target.raise(klass || Slow, "maybe") }
[nil, ArgumentError].each do |k|
  t = Thread.new do
    watch_maybe(Thread.current, k, 0.05)
    sleep 1
  rescue StandardError => e
    [e.class, e.message]
  end
  p t.value
end

# a message that may be nil (`message || "default"` left to the callee)
def watch_msg(target, klass, message, sec) = Thread.new { sleep sec; target.raise(klass, message || "expired") }
[nil, "custom"].each do |m|
  t = Thread.new do
    watch_msg(Thread.current, Slow, m, 0.05)
    sleep 1
  rescue Slow => e
    e.message
  end
  p t.value
end
