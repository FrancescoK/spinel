# Flag-only: without the flag (as on master) the parameter is a copy and misses the change.
# A parameter the callee only reads, bound to a String the callee changes
# through another name while the parameter is live (#6765). In CRuby the two
# names are one object, so the parameter sees the change. Without the flag
# the parameter is a copy taken at the call and reads the old bytes; under
# --share-strings such a parameter joins its argument's share class and is
# the same handle. Run with --share-strings (make share-strings-test).

class H
  def initialize
    @buf = +"abcde"
    @buf.setbyte(0, 97)
    @grow = -> { @buf << "p" * 3 }
  end

  # the callee changes the same ivar
  def grow_then_read(s)
    @buf << "x" * 100
    s.bytesize
  end

  # through a local it aliases to the ivar
  def via_alias(s)
    b = @buf
    b << "yy"
    s.bytesize
  end

  # in a block
  def via_block(s)
    [1, 2].each { @buf << "z" }
    s.bytesize
  end

  # in a method the callee calls
  def helper = @buf << "w" * 10

  def via_helper(s)
    helper
    s.bytesize
  end

  # through a proc held in an ivar
  def via_proc(s)
    @grow.call
    s.bytesize
  end

  # through a method the callee calls by send
  def via_send(s)
    send(:helper)
    s.bytesize
  end

  # handed on to a callee that changes it
  def pass_through(s) = grow_then_read(s)

  # a literal argument is no other name
  def literal = grow_then_read("lit")

  # an alias makes @buf shared before the flag too
  def peek
    b = @buf
    b
  end

  def run = [grow_then_read(@buf), via_alias(@buf), via_block(@buf), via_helper(@buf),
             via_proc(@buf), via_send(@buf), send(:grow_then_read, @buf),
             pass_through(@buf), literal, @buf.bytesize]
end

p H.new.run

# the same String as two arguments, one changed
def both(s, t)
  t << "x"
  s.bytesize
end

def both_nested(s, t) = both(s, t)

b = +"abc"
p both(b, b)
p both_nested(b, b)
p send(:both, b, b)
p b

# near misses that keep the copy: the callee changes only its own String,
# and an accumulator grown through its parameter
def own(s)
  o = +"k"
  o << "j"
  s.bytesize + o.size
end

d = +"zz"
d << "w"
p own(d)

def grow(acc, x) = acc << x

e = +""
3.times { |i| grow(e, i.to_s) }
p e

# a later argument of the same call changes the String the callee reads:
# CRuby evaluates every argument first, so the callee sees the change
def len_plus(a, n) = a.bytesize + n
def len2(a, b) = a.bytesize + b.bytesize
def grow2(s) = (s << "zz"; 1)
@lb = +"ab"
lt = @lb
p len_plus(@lb, (lt << "cde").size)
p len2(@lb, (lt << "x"; @lb))
p len_plus(@lb, grow2(@lb))
lu = +"u"
p len_plus(lu, (lu << "vw").size)
