# A parameter no typed call binds -- a Thread block's, which Thread.new's
# arguments do not type -- is widened to poly after the main fixpoint. A
# method that answers it on one class and an object of another class on a
# subclass then answers either, and a parameter that value reaches holds
# either: it is not left typed as the subclass's object alone, which made
# the IO a TypeError at the call.

class Link
  def initialize(conn)
    @conn = conn
  end

  def deliver(bytes) = @conn.write(bytes)
end

class Sealed
  def initialize(io)
    @io = io
  end

  def write(bytes) = @io.write(bytes.reverse)
end

class Plain
  def serve(conn)
    stream = wrap(conn)
    Link.new(stream).deliver("Seongsu")
  end

  def wrap(conn) = conn
end

class Secure < Plain
  def wrap(conn) = Sealed.new(conn)
end

r, w = IO.pipe
Thread.new(w) { |c| p Plain.new.serve(c) }.join
Thread.new(w) { |c| p Secure.new.serve(c) }.join
w.close
p r.read
