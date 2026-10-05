# A shared String handed to a parameter that only reads it (#7482). Under
# --share-strings such a parameter borrows the handle's buffer for the length
# of the call instead of a copy; a parameter that keeps the String, matches
# it, or runs beside a change to it still gets its own. Every answer is the
# same with and without the flag.

class Buf
  attr_reader :kept

  def initialize
    @buf = +"abc"
    @buf << "d"
  end

  def alias_it
    b = @buf
    b << "e"
  end

  def self.len(s) = s.bytesize
  def self.byte(s, i) = s.getbyte(i % 4)
  def self.empty(s) = s.empty?
  def self.matched(s) = s =~ /c/

  def keep(s)
    @kept = s
    s.size
  end

  def run
    alias_it
    r = []
    r << Buf.len(@buf)
    r << Buf.byte(@buf, 6)
    r << Buf.empty(@buf)
    r << Buf.matched(@buf)
    r << keep(@buf)
    @buf << "y"
    r << @buf.size
    r
  end
end

b = Buf.new
p b.run

def total(s, n)
  t = 0
  n.times { |i| t += s.getbyte(i % s.bytesize) }
  t
end

def width(s) = s.length

s = +"hello"
t = s
t << " world"
p width(s)
p total(s, 3)
q = nil
q = +"x" if s.size > 3
w = q
w << "z" if w
p width(q)
