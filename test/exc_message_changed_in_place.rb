# spinel: gc-stress
# The message of an exception is the String it was raised or built with, so
# a change to the message in place is a change to that String, and the other
# way round. The message here comes from a variable, a reader, a method's
# answer or a conversion, through each way to raise or build an exception.
class Holder
  attr_reader :ar
  def initialize(x)
    @s = x
    @ar = x
  end
  def s = @s
end
class MyErr < StandardError; end
class MyErr2 < StandardError
  def initialize(m) = super(m)
end
class SuperReader < StandardError
  def initialize(h) = super(h.s)
end
class SuperConv < StandardError
  def initialize(m) = super(String(m))
end
class SuperTwo < StandardError
  def initialize(m, n) = super(m)
end

def check(name, s)
  yield s
rescue Exception => e
  m = e.message
  same = m.equal?(s)
  m << "!" unless m.frozen?
  puts "#{name}: #{same} #{s.inspect}"
end

check("raise s", +"a") { |s| raise s }
check("raise Klass, s", +"a") { |s| raise RuntimeError, s }
check("raise Klass, s, bt", +"a") { |s| raise RuntimeError, s, [] }
check("raise MyErr, s", +"a") { |s| raise MyErr, s }
check("MyErr.new(s)", +"a") { |s| raise MyErr.new(s) }
check("MyErr2.new(s)", +"a") { |s| raise MyErr2.new(s) }
check("MyErr2, s", +"a") { |s| raise MyErr2, s }
check("SuperConv.new(s)", +"a") { |s| raise SuperConv.new(s) }
check("SuperTwo.new(s, 1)", +"a") { |s| raise SuperTwo.new(s, 1) }
check("exception(s)", +"a") { |s| raise RuntimeError.exception(s) }
check("reader method", +"a") { |s| raise Holder.new(s).s }
check("attr_reader", +"a") { |s| raise Holder.new(s).ar }
check("reader, Klass, s", +"a") { |s| raise RuntimeError, Holder.new(s).s }
check("reader, MyErr.new", +"a") { |s| raise MyErr.new(Holder.new(s).s) }
check("reader, RuntimeError.new", +"a") { |s| raise RuntimeError.new(Holder.new(s).s) }
check("super(reader)", +"a") { |s| raise SuperReader.new(Holder.new(s)) }
check("e, reader", +"a") { |s| raise RuntimeError.new("x"), Holder.new(s).s }
check("conditional", +"a") { |s| raise(s.size > 0 ? s : "none") }
check("String()", +"a") { |s| raise String(s) }
check("to_s", +"a") { |s| raise s.to_s }
check("re-raise by class and message", +"a") { |s|
  begin
    raise s
  rescue => e
    raise e.class, e.message
  end
}
check("a copy", +"a") { |s| raise s.dup }

# an exception made outside a raise keeps the String too
def made(name, s)
  x = yield s
  x.message << "!"
  puts "#{name}: #{s.inspect}"
end
made("Klass.exception", +"a") { |s| RuntimeError.exception(s) }
made("e.exception", +"a") { |s| RuntimeError.new("q").exception(s) }
made("Klass.new", +"a") { |s| ArgumentError.new(s) }

# a formatted message is a new String
s4 = +"dm"
begin
  raise s4
rescue => e
  dm = e.detailed_message(highlight: false)
  dm << "!"
  p s4
end
