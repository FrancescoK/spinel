# A String mutated in place and aliased is a shared handle; a call that
# passes it to a read-only parameter reads its live buffer (#7482: each
# call copied the whole buffer, O(length) per call).
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
h = Holder.new(200_000)
p h.run(30_000_000)
