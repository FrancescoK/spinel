# spinel: gc-stress
# The String an exception is raised or built with is its message: #message
# answers that String itself, not a copy of it. A program that only compares
# the two by identity (nothing changes either in place) has to see the same
# String too. Here the message is a variable's String, a reader's or a
# method's answer, a conversion of it, a conditional's, and goes to
# `raise s`, `raise Klass, s` (with and without a backtrace), `Klass.new(s)`,
# `Klass.exception(s)` and `super(s)` of an exception's initialize.
class Holder
  attr_reader :ar
  def initialize(x)
    @s = x
    @ar = x
  end
  def s = @s
end
class MyErr < StandardError; end
class SuperErr < StandardError
  def initialize(h) = super(h.s)
end

def check(name, s)
  yield s
rescue Exception => e
  m = e.message
  puts "#{name}: #{m.equal?(s)} #{s.equal?(m)} #{m.object_id == s.object_id}"
end

check("raise s", +"a") { |s| raise s }
check("fail s", +"a") { |s| fail s }
check("raise Klass, s", +"a") { |s| raise RuntimeError, s }
check("raise Klass, s, bt", +"a") { |s| raise RuntimeError, s, [] }
check("raise Klass, s, cause", +"a") { |s| raise RuntimeError, s, cause: nil }
check("raise MyErr, s", +"a") { |s| raise MyErr, s }
check("raise MyErr.new(s)", +"a") { |s| raise MyErr.new(s) }
check("raise RuntimeError.new(s)", +"a") { |s| raise RuntimeError.new(s) }
check("exception(s)", +"a") { |s| raise RuntimeError.exception(s) }
check("exception on an instance", +"a") { |s| raise RuntimeError.new("x").exception(s) }
check("reader method", +"a") { |s| raise Holder.new(s).s }
check("attr_reader", +"a") { |s| raise Holder.new(s).ar }
check("reader, Klass, s", +"a") { |s| raise RuntimeError, Holder.new(s).s }
check("reader, Klass, s, bt", +"a") { |s| raise RuntimeError, Holder.new(s).s, [] }
check("reader, MyErr.new", +"a") { |s| raise MyErr.new(Holder.new(s).s) }
check("reader, RuntimeError.new", +"a") { |s| raise RuntimeError.new(Holder.new(s).s) }
check("super(reader)", +"a") { |s| raise SuperErr.new(Holder.new(s)) }
check("parenthesized", +"a") { |s| raise((s)) }
check("conditional", +"a") { |s| raise(s.size > 0 ? s : "none") }
check("itself", +"a") { |s| raise s.itself }
check("String()", +"a") { |s| raise String(s) }
check("to_s", +"a") { |s| raise s.to_s }
check("then", +"a") { |s| raise s.then { |q| q } }
check("hash element", +"a") { |s| raise({ k: s }[:k]) }
check("Array element", +"a") { |s| raise [s].first }
check("a copy", +"a") { |s| raise s.dup }
check("a literal", +"a") { |s| raise "lit" }

# a conversion of the message answers the message
s2 = +"conv"
begin
  raise s2
rescue => e
  p e.message.itself.equal?(e.message), e.message.to_s.equal?(s2), String(e.message).equal?(s2)
end

# a formatted message is a new String, kept in a variable or not
s3 = +"fm"
begin
  raise s3
rescue => e
  fm = e.full_message(highlight: false)
  dm = e.detailed_message(highlight: false)
  p fm.equal?(s3), dm.equal?(s3), e.message.equal?(s3), fm.include?("fm")
end
