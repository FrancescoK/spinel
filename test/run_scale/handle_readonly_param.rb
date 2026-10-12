# run-scale: 100000 100 | 100000 1600 | 1.5
# #7482: a String mutated in place and aliased becomes a shared handle, and
# each call that passes it to a read-only parameter copied the whole buffer.
# The bytes allocated must not grow with the number of calls (16x here).
class Holder
  def initialize(len)
    @buf = "\0".b * len
    @buf.setbyte(0, 7)
  end
  def self.use(s, i) = s.getbyte(i % 64)
  def peek
    b = @buf
    b.getbyte(1)
  end
  def run(n)
    t = 0
    n.times { |i| t += Holder.use(@buf, i) }
    t
  end
end
p Holder.new(ARGV[0].to_i).run(ARGV[1].to_i)
