# A widened parameter's value is stored into the ivars it reaches before
# the returns are derived again. Hop#run hands what Plain#wrap answers back
# to itself, and in the main fixpoint that recursive call was the one typed
# caller of its `conn`: with `conn` unknown, `wrap` answered Secure#wrap's
# Sealed. So `Sealed.new(conn)` made `@io` a Sealed, and Sealed#write,
# which answers `@io.write`, called only itself and had no value. Plain#serve's
# `conn`, a Thread block's argument that no typed call binds, is widened
# after the fixpoint, and the widening reaches Hop#run's `conn` and
# Sealed#initialize; `@io` widened only after the last pass that gives a
# method with no value its return. Sealed#write and Link#deliver were
# emitted void, and every thread printed nil.

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
  def serve(conn, place) = Link.new(wrap(conn)).deliver(place)
  def wrap(conn) = conn
end

class Secure < Plain
  def wrap(conn) = Sealed.new(conn)
end

class Hop
  def run(conn, n)
    stream = n.zero? ? Plain.new.wrap(conn) : conn
    n < 3 ? run(stream, n + 1) : Link.new(stream).deliver("Kondae")
  end
end

r, w = IO.pipe
Thread.new(w) { |c| p Plain.new.serve(c, "Seongsu") }.join
Thread.new(w) { |c| p Secure.new.serve(c, "Achasan") }.join
Thread.new(w) { |c| p Hop.new.run(c, 0) }.join
w.close
p r.read
