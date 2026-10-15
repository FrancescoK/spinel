# spinel: share
# A shared String handed on through a method to a read-only parameter
# borrows the buffer as a direct call does (#9229), through any number of
# hand-offs. Every answer is CRuby's.
class Buf
  def initialize
    @buf = +"abc"
    @buf << "d"
  end

  def self.byte(s, i) = s.getbyte(i % 4)
  def self.fwd(s, i) = byte(s, i)
  def self.twice(s, i) = fwd(s, i) + fwd(s, i + 1)

  def run
    b = @buf
    b << "e"
    [Buf.fwd(@buf, 1), Buf.twice(@buf, 2), @buf]
  end
end

p Buf.new.run
