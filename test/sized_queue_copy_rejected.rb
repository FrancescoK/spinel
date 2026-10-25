# spinel: gc-stress
# Queue and SizedQueue have no initialize_copy: dup and clone raise
# NoMethodError for it, typed or boxed, and leave the queue as it was.
class Foo
  def dup = :foo
end

def t
  yield
rescue => e
  p [e.class, e.message, e.name, e.receiver.class, e.receiver.equal?(e.args[0]), e.args.size]
end

q = SizedQueue.new(1)
begin
  copy = q.dup
  p copy.class
rescue => error
  p error.class
end

q = SizedQueue.new(2); q << 1
t { p q.dup.class }
t { p q.clone.class }
r = Queue.new; r << 5; r.close
t { p r.dup.class }
t { p r.clone.class }
p [q.size, q.pop, r.size, r.closed?]
[SizedQueue.new(3), Queue.new, Foo.new].each do |b|
  t { p b.dup }
  t { p b.clone.class }
end
p [q.respond_to?(:dup), r.respond_to?(:clone)]
x = [Queue.new, nil][1]
p x.dup
w = [Queue.new, 1][0]
t { p w.clone(freeze: false) }
t { p w.clone(freeze: true) }
