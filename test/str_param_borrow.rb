# A shared String handed to a parameter that only reads it (#7482). A String
# with a second name that is changed in place is a shared handle, and a
# handle passed to a `const char *` parameter was copied in full at every
# call. A parameter whose every use is a read-only accessor (getbyte,
# bytesize, length, size, empty?) in a callee that runs no other code takes
# the live buffer; a parameter kept, matched or changed, or a callee that
# calls further, still gets its own copy. Every answer is CRuby's.

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

  # borrow: reads only
  def self.len(s) = s.bytesize
  def self.byte(s, i) = s.getbyte(i % 4)
  def self.empty(s) = s.empty?
  def self.both(s, t) = s.size + t.length

  # copy: the parameter is matched (MatchData keeps the String)
  def self.matched(s) = s =~ /c/

  # copy: the parameter is kept
  def keep(s)
    @kept = s
    s.size
  end

  # copy: the parameter is changed (the caller's String grows)
  def self.grow(s) = s << "!"

  # copy: the callee makes a dynamic call
  def self.dyn(s) = s.size + [1, 2].send(ARGV.empty? ? :size : :first)

  # copy: the callee calls another method
  def self.nested(s) = s.size + helper
  def self.helper = 1

  # copy: the callee changes the String through another name, after the
  # parameter's last read
  def read_then_grow(s)
    n = s.bytesize
    @buf << "x" * 100
    n
  end

  def run
    alias_it
    r = []
    r << Buf.len(@buf)
    r << Buf.byte(@buf, 6)
    r << Buf.empty(@buf)
    r << Buf.both(@buf, @buf)
    r << Buf.matched(@buf)
    r << keep(@buf)
    r << Buf.dyn(@buf)
    r << Buf.nested(@buf)
    r << read_then_grow(@buf)
    r << @buf.size
    Buf.grow(@buf)
    r << @buf[-1]
    r
  end
end

p Buf.new.run

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
