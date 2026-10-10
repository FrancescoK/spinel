# A call that answers its receiver, kept in an instance variable, is the
# receiver's String when an argument sets the receiver's variable inline
# (`@s.bytesplice(0, 1, (@s = @t; x))`): the call mutates and answers the
# String the receiver held before its arguments ran, and the argument's write
# stands. The same with a local receiver, and with a parenthesized sequence
# before the answered receiver.
class Inline
  def initialize(s) = (@s = s; @t = +"zz")

  def read = [@s, @r]

  def lshift(x) = (@r = @s << (@s = @t; x.upcase); @r << "!"; @s)
  def insert(x) = (@r = @s.insert(0, (@s = @t; x.upcase)); @r << "!"; @s)
  def concat2(x) = (@r = @s.concat((@s = @t; x.upcase), "y"); @r << "!"; @s)
  def prepend2(x) = (@r = @s.prepend((@s = @t; x.upcase), "y"); @r << "!"; @s)
  def append_as_bytes2(x) = (@r = @s.append_as_bytes((@s = @t; x.upcase), "y"); @r << "!"; @s)
  def bytesplice(x) = (@r = @s.bytesplice(0, 1, (@s = @t; x.upcase)); @r << "!"; @s)
  def statement(x) = (@s.bytesplice(0, 1, (@s = @t; x.upcase)); @s)
end
%i[lshift insert concat2 prepend2 append_as_bytes2 bytesplice statement].each do |m|
  i = Inline.new(+"abc")
  p [m, i.send(m, "q")]
  p i.read
end

# a local receiver, the same
def local_bytesplice(x)
  s = +"abc"
  r = s.bytesplice(0, 1, (s = +"zz"; x.upcase))
  r << "!"
  [s, r]
end
def local_insert(x)
  s = +"abc"
  r = s.insert(0, (s = +"zz"; x.upcase))
  r << "!"
  [s, r]
end
def local_concat2(x)
  s = +"abc"
  r = s.concat((s = +"zz"; x.upcase), "y")
  r << "!"
  [s, r]
end
p local_bytesplice("q")
p local_insert("q")
p local_concat2("q")

# a parenthesized sequence before the answered receiver: its statements run,
# and the instance variable is the receiver's String (@q counts the statements
# before it)
class Sequence
  def initialize(s) = (@s = s; @q = 0)

  def lshift = (@r = (@q += 1; @s << "x"); @r << "!"; [@q, @s, @r])
  def alias_bytesplice = (@r = (@q += 1; t = @s; t.bytesplice(0, 1, "Z")); @r << "!"; [@q, @s, @r])
  def alias_read = (@r = (@q += 1; t = @s; t); @r << "!"; [@q, @s, @r])
  def bytesplice = (@r = (@q += 1; @s.bytesplice(0, 1, "Z")); @r << "!"; [@q, @s, @r])
  def concat2 = (@r = (@q += 1; @s.concat("x", "y")); @r << "!"; [@q, @s, @r])
  def read = (@r = (@q += 1; @s); @r << "!"; [@q, @s, @r])
  def two = (@r = (@q += 1; @q += 1; @s); @r << "!"; [@q, @s, @r])
end
%i[lshift alias_bytesplice alias_read bytesplice concat2 read two].each do |m|
  p [m, Sequence.new(+"abc").send(m)]
end

# the same where the instance variable's slot is a box (the methods write it
# with different shapes of one answered String)
class Boxed
  def initialize(s) = (@s = s; @q = 0)

  def alias_bytesplice = (@r = (@q += 1; t = @s; t.bytesplice(0, 1, "Z")); @r << "!"; [@q, @s, @r])
  def alias_lshift = (@r = (@q += 1; t = @s; t << "x"); @r << "!"; [@q, @s, @r])
  def alias_read = (@r = (@q += 1; t = @s; t); @r << "!"; [@q, @s, @r])
  def seq_lshift = (@r = (@q += 1; @s << "x"); @r << "!"; [@q, @s, @r])
  def seq_bytesplice = (@r = (@q += 1; @s.bytesplice(0, 1, "Z")); @r << "!"; [@q, @s, @r])
end
%i[alias_bytesplice alias_lshift alias_read seq_lshift seq_bytesplice].each do |m|
  p [m, Boxed.new(+"abc").send(m)]
end
