# A program class's zero-arity to_i must not widen String#to_i(base) on a
# boxed receiver: the emitter answers that call as an unboxed Integer, and a
# consumer that read it as boxed failed the C build (`buf << s.to_i(16)`).
class Opts
  def initialize(v)
    @v = v
  end

  def to_i
    @v
  end
end

def decode(s)
  hex = s.getbyte(0).chr + s.getbyte(1).chr
  out = String.new
  out << hex.to_i(16)
  out
end

o = ARGV.empty? ? Opts.new(1) : Opts.new("x")
p o.to_i
p decode("41")
p decode(ARGV.empty? ? "42" : 7)
n = (ARGV.empty? ? "ff" : 3).to_i(16)
p n + 1
