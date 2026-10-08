# A builtin call on a shared String ivar, whose argument is a call, mutates
# the ivar's own String. Ordering the receiver ahead of the argument bound the
# ivar to a temp, and for a shared String slot that read is the value form, a
# COPY: `@buf.setbyte(idx, 90)` wrote into the copy, and the object and every
# alias of it kept the old byte.
# spinel: gc-minor
class Buf
  attr_reader :buf

  def initialize
    @buf = +"ab"
  end

  def suffix
    @n = (@n || 0) + 1
    "x#{@n}"
  end

  def idx
    @n = (@n || 0) + 1
    0
  end

  def run
    @buf << suffix
    @buf.concat(suffix)
    @buf.setbyte(idx, 90)
    @buf.insert(idx, "Q")
    @buf.replace(@buf + suffix)
    @buf
  end
end

b = Buf.new
alias_of = b.buf
p b.run
p alias_of
p alias_of.getbyte(1)
