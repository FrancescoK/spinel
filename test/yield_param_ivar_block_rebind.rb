# A yielding method spliced at its call site binds a String parameter the
# body reads to an instance variable argument by value wherever something
# can assign that variable while the body runs. A method the block calls
# on self (`m(@s) { reset }`) and a proc passed as the block (`m(@s,
# &pr)`) can, and were not counted: the parameter followed the variable to
# its new String. Each case has a method of its own.
def show1(w)
  yield
  p w
  nil
end

def show2(w)
  yield
  p w
  nil
end

class Resetter
  def go
    @s = "a"
    show1(@s) { reset }
    p @s
  end

  def reset = (@s = "b")
end

class ProcWriter
  def go
    @s = "a"
    pr = proc { @s = "b" }
    show2(@s, &pr)
    p @s
  end
end

Resetter.new.go
ProcWriter.new.go
