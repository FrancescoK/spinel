# Two Integer Array element reads that may be nil, at a boxed index, passed
# straight to a method that uses them as operands: each is unwrapped once,
# at the call, with the error the callee's first use would raise (#8576).
class File16
  def initialize(bytes) = @bytes = bytes
  def uint16(low, high) = (high << 8) + low
  def word(offset) = uint16(@bytes[offset + 1], @bytes[offset])
  def word_local(offset)
    w = uint16(@bytes[offset + 1], @bytes[offset])
    w
  end
end

module IntegerHelper
  def uint16(low, high) = (high << 8) + low
end

class File16M
  include IntegerHelper
  def initialize(bytes) = @bytes = bytes
  def word(offset) = uint16(@bytes[offset + 1], @bytes[offset])
end

f = File16.new("\x12\x34\x56".bytes)
p f.word(0)
p f.word([1, "x"][0])
p f.word_local([1, "x"][0])
p File16M.new("\x12\x34\x56".bytes).word([1, "x"][0])
begin
  f.word([5, "x"][0])
rescue NoMethodError => e
  puts e.message.tr("`", "'")
end
