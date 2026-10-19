# A widened parameter's value travels a call a round through the locals and
# returns it reaches. Here a Thread block's IO goes through five classes
# before it reaches Link.new, about two rounds a class, and the re-bind
# stopped at eight rounds: Link#initialize kept the Sealed that Secure#wrap
# answers, and the IO was a TypeError at the call.

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
  def wrap(conn) = conn
end

class Secure < Plain
  def wrap(conn) = Sealed.new(conn)
end

class Seongsu
  def run(conn)
    stream = Plain.new.wrap(conn)
    Jayang.new.run(stream)
  end
end

class Jayang
  def run(conn)
    stream = pass(conn)
    Kondae.new.run(stream)
  end

  def pass(conn) = conn
end

class Kondae
  def run(conn)
    stream = pass(conn)
    Guui.new.run(stream)
  end

  def pass(conn) = conn
end

class Guui
  def run(conn)
    stream = pass(conn)
    Achasan.new.run(stream)
  end

  def pass(conn) = conn
end

class Achasan
  def run(conn)
    stream = pass(conn)
    Link.new(stream).deliver("Children's Grand Park")
  end

  def pass(conn) = conn
end

r, w = IO.pipe
Thread.new(w) { |c| p Seongsu.new.run(c) }.join
w.close
p r.read
