# Under --share-strings, a String parameter its method only reads and
# appends to is lent its argument's slot. An instance variable argument
# that a method the block calls assigns (`m(@s) { reset }`), or a proc
# passed as the block assigns, rebinds that slot while the method runs:
# the appends after the yield landed on the new String. Such a call lends
# nothing; the parameter shares the variable's String instead.
def m1(v)
  yield
  v << "x"
  nil
end

def m2(v)
  yield
  v << "x"
  nil
end

class Resetter
  def go
    @s = +"a"
    m1(@s) { reset }
    p @s
  end

  def reset = (@s = +"b")
end

class ProcWriter
  def go
    @s = +"a"
    pr = proc { @s = +"b" }
    m2(@s, &pr)
    p @s
  end
end

Resetter.new.go
ProcWriter.new.go
