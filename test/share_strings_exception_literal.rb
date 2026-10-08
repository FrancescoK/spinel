# An exception's message given as a literal is that frozen literal, so
# `e.message << x` raises FrozenError and `e.message.frozen?` is true, in
# every raise and construction form. An interpolated message and
# the class name a message-less exception answers are not frozen.
class E < StandardError; end
class F < StandardError
  def initialize(m) = super(m)
end
class G < StandardError
  def initialize(m)
    @k = 1
    super(m)
  end
end
fs = [-> { raise ArgumentError, "lit" }, -> { raise "lit" }, -> { fail "lit" }, -> { raise ArgumentError.new("lit") },
      -> { raise E, "lit" }, -> { raise E.new("lit") }, -> { raise F.new("lit") }, -> { raise G.new("lit") },
      -> { raise ArgumentError, "a\0b" }, -> { raise ArgumentError, "x#{1}" }, -> { raise ArgumentError }]
fs.each do |f|
  begin
    f.call
  rescue => e
    p [e.class, e.message.frozen?]
    begin
      e.message << "!"
    rescue FrozenError => fe
      p fe.class
    end
  end
end
p ArgumentError.new("lit").message.frozen?, E.new("lit").message.frozen?
begin
  raise "lit"
rescue => e
  p e.full_message(highlight: false).include?("lit"), e.inspect
end
# across a Thread's join, a Fiber's resume and a bare re-raise
Thread.report_on_exception = false
begin
  Thread.new { raise ArgumentError, "lit" }.join
rescue => e
  p e.message, e.message.frozen?
end
fb = Fiber.new { raise "fib" }
begin
  fb.resume
rescue => e
  p e.message, e.message.frozen?
end
begin
  begin
    raise "inner"
  rescue
    raise
  end
rescue => e2
  p e2.message, e2.message.frozen?
end
# an empty literal message is the frozen literal too, in every form; a bare
# raise's and an unfrozen "" are not frozen
[-> { raise ArgumentError, "" }, -> { raise "" }, -> { fail "" }, -> { raise ArgumentError.new("") },
 -> { raise E, "" }, -> { raise E.new("") }, -> { raise F.new("") }, -> { raise G.new("") },
 -> { Thread.new { raise ArgumentError, "" }.join }, -> { Fiber.new { raise "" }.resume },
 -> { begin; raise ""; rescue; raise; end }].each do |f|
  begin
    f.call
  rescue => e
    p [e.class, e.message, e.message.frozen?]
    begin
      e.message << "!"
    rescue FrozenError => fe
      p fe.class
    end
  end
end
[-> { raise }, -> { raise ArgumentError, "".dup }].each do |f|
  begin
    f.call
  rescue => e
    p [e.class, e.message, e.message.frozen?]
  end
end
p ArgumentError.new("").message.frozen?, E.new("").message
# Exception#exception(msg) keeps an explicitly given message as `new` does:
# an empty one stays empty (frozen for a literal), a literal's stays
# frozen, nil gives the class name, and no argument answers the receiver.
ex = ArgumentError.new("orig")
[-> { ex.exception("") }, -> { ex.exception(+"") }, -> { ex.exception(nil) }, -> { ex.exception("x") },
 -> { ex.exception(+"y") }, -> { ex.exception }].each do |f|
  x = f.call
  p [x.message, x.message.frozen?, x.equal?(ex)]
end
