# Flag-only: an exception raised or built with a String holds that String
# as its message, so a change through `e.message` (or `e.to_s`) shows in
# the String, and a change to the String shows in `e.message`, `inspect`,
# `full_message`, `==` and a re-raise: `raise C, s`, `raise C.new(s)`, a
# class of the program with and without its own initialize (`super(m)`),
# with instance variables, `raise s` and `fail s`. `e.exception(t)` holds
# t, not s. A message that is a literal or an unshared String keeps its
# own copy.
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
s = +"ab"
[-> { raise ArgumentError, s }, -> { raise ArgumentError.new(s) }, -> { raise E, s }, -> { raise E.new(s) },
 -> { raise F.new(s) }, -> { raise G.new(s) }, -> { raise s }, -> { fail s }].each_with_index do |f, i|
  begin
    f.call
  rescue => e
    e.message << i.to_s
    m = e.message
    m << "."
    p [e.message, s, e.class]
  end
end
t = +"t"
x = ArgumentError.new(t)
t << "1"
p x.message, x.inspect, x.full_message(highlight: false).include?("t1")
x.to_s << "2"
p t
y = ArgumentError.new(+"t12")
p x == y
begin
  raise x
rescue => e
  p e.message, e.equal?(x)
end
z = x.exception("other")
p z.message, x.message
t << "3"
p z.message, x.message
u = +"u"
begin
  raise RuntimeError, u
rescue => e
  u << "!"
  p e.message
  begin
    raise
  rescue => e2
    p e2.message
  end
end
begin
  raise ArgumentError, "lit"
rescue => e
  p e.message
end
w = +"w"
begin
  raise ArgumentError, w.dup
rescue => e
  e.message << "?"
  p w
end
# The message is the String itself: equal? to it, and to itself.
v = +"v"
begin
  raise ArgumentError, v
rescue => e
  p e.message.equal?(e.message), e.message.equal?(v), v.equal?(e.message)
end
begin
  raise ArgumentError, "x#{1}"
rescue => e
  e.message << "!"
  p e.message, e.message.equal?(e.message)
end
begin
  raise ArgumentError
rescue => e
  e.message << "!"
  p e.message, e.message.equal?(e.message)
end
# Exception#exception(s) holds s as its message too.
w2 = +"w2"
ex2 = ArgumentError.new("orig").exception(w2)
w2 << "!"
p ex2.message, ex2.message.equal?(w2)
