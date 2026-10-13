# append_as_bytes and bytesplice took only a String receiver. Under
# --share-strings a method that answers its parameter (`rec(s) = s`) answers
# the handle when its answer is changed, and in both builds a reader of an
# ivar that holds the handle answers it: the two mutators had no arm for the
# handle and were refused, where every other String mutator takes it. They
# now change the handle in place, raising FrozenError for a frozen String.
def rec(s) = s
begin; rec("lit").append_as_bytes("x"); rescue => e; p e.class; end
begin; rec("lit").append_as_bytes; rescue => e; p e.class; end
begin; rec("lit").append_as_bytes("x", 100); rescue => e; p e.class; end
begin; rec("lit").bytesplice(0, 1, "Z"); rescue => e; p e.class; end
begin; rec("lit").bytesplice(0..0, "Z"); rescue => e; p e.class; end
class Buf
  def initialize; @s = +"buf"; @f = "lit"; end
  def get = @s
  def frozen_one = @f
  def show = p(@s)
end
b = Buf.new
b.get.append_as_bytes("!", 63)
b.get.bytesplice(0, 1, "B")
b.get.bytesplice(1..2, "UF")
b.get.append_as_bytes
b.show
begin; b.frozen_one.append_as_bytes("!"); rescue => e; p e.class; end
begin; b.frozen_one.bytesplice(0, 1, "B"); rescue => e; p e.class; end
begin; b.frozen_one.append_as_bytes; rescue => e; p e.class; end
p b.frozen_one
