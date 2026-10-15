# run-scale: 100000 100 | 100000 1600 | 1.5
# #9229: a shared handle passed to a method that only hands it on to a
# read-only parameter was copied in full at every call, as #7482's direct
# call was before. The bytes allocated must not grow with the calls.
class Holder
  def initialize(len)
    @buf = "\0".b * len
    @buf.setbyte(0, 7)
  end
  def self.at(s, i) = s.getbyte(i % 64)
  def self.sum(s, i) = at(s, i)
  def peek
    b = @buf
    b.getbyte(1)
  end
  def run(n)
    t = 0
    n.times { |i| t += Holder.sum(@buf, i) }
    t
  end
end
p Holder.new(ARGV[0].to_i).run(ARGV[1].to_i)
