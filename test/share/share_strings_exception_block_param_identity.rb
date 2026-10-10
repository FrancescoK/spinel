# spinel: share
# spinel: gc-minor
# A block parameter holding an exception none of whose class overrides the
# text and one that returns a String of its own answers the same message
# object on every read, so a message compares by identity with itself, with
# its to_s and with the message of the same exception beside it. The Array
# iterated is a variable or a literal.
class B < StandardError; end
class A < StandardError
  def to_s = "over"
end
class T < StandardError
  def initialize(t)
    @t = t
    super("st")
  end
  def message = @t
end
n = ARGV.size
arr = [B.new("a#{n}"), T.new(+"tt")]
arr.each_with_index { |x, i| p [i, x.message.equal?(x.message)] }
[B.new("l#{n}"), T.new(+"lt")].each_with_index { |x, i| p [:lit, i, x.message.equal?(x.message)] }
xs = [B.new("a#{n}"), A.new, B.new, T.new(+"tt")]
xs.each_with_index { |x, i| p [i, x.message.equal?(x.message), x.message.equal?(x.to_s)] }
[B.new("a#{n}"), A.new, B.new, T.new(+"tt")].each_with_index { |x, i| p [:lit, i, x.message.equal?(x.message), x.message.equal?(x.to_s)] }
xs.each { |x| p x.message.equal?(x.message) }
p xs.map { |x| x.message.equal?(x.message) }
t = T.new(+"tm")
v = t.message
v << "!"
p t.message, t.message.equal?(v), t.message.equal?(t.message)
