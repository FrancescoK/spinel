# close on a boxed value when a user class also defines #close: the
# Queue answers itself, an IO or Dir nil, and the user's class its own.

class Conn
  def close = :conn_closed
end

q = Queue.new
r, w = IO.pipe
items = [q, w, Dir.new("."), Conn.new]
p items.map { |i| i.close }.map { |v| v.equal?(q) ? :queue : v }
p q.closed?
p w.closed?
r.close
