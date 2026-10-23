# A builtin class whose values Spinel holds in a kind of their own -- Time,
# Thread, Fiber, Random, File and IO, Class -- and a native class declared
# under a qualified name (IO::Buffer) can be named in a signature or a
# declaration. The values arrive boxed, out of a poly container, so each
# annotation is what types its slot. A Range and an exception class name more
# values than one kind holds (a Float Range, the program's own exception
# class): the annotation applies and leaves that slot to inference.
class AppError < StandardError
end

class Kit
  # @rbs @at: Time?

  #: (Time t) -> Integer
  def secs(t) = t.to_i

  #: (Range r) -> Integer
  def total(r) = r.sum

  #: (Thread th) -> Integer
  def joined(th) = th.value

  #: (Fiber f) -> Integer
  def resumed(f) = f.resume

  #: (Random g) -> String
  def gen_class(g) = g.class.name

  #: (IO io) -> Integer
  def fd(io) = io.fileno

  #: (Class k) -> String
  def named(k) = k.name

  #: (StandardError e) -> String
  def said(e) = e.message

  #: (Errno::ENOENT e) -> String
  def errno(e) = e.class.name

  #: (IO::Buffer b, Integer i) -> Integer
  def byte_at(b, i) = b.get_value(:U8, i)

  #: (Time? t) -> void
  def stamp(t)
    @at = t
  end

  def at = @at
end

buf = IO::Buffer.new(4)
buf.set_value(:U8, 2, 7)
vals = [Time.at(86_400).utc, (1..4), Thread.new { 6 }, Fiber.new { 5 }, Random.new(1),
        $stdout, Integer, ArgumentError.new("bad"), buf, 0]
k = Kit.new
p k.secs(vals[0])
p k.total(vals[1])
p k.joined(vals[2])
p k.resumed(vals[3])
p k.gen_class(vals[4])
p k.fd(vals[5])
p k.named(vals[6])
p k.said(vals[7])
p k.said(AppError.new("mine"))
p k.total(1..2)
begin
  File.open("/nonexistent/spinel/inline-rbs")
rescue Errno::ENOENT => e
  p k.errno(e)
end
p k.byte_at(vals[8], 2)
k.stamp(vals[0])
p k.at.year
k.stamp(nil)
p k.at
