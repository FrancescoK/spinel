# The dishonest half: the signature says Integer, the program stores a String.
# Without -DSP_RBS_CHECK this prints the String pointer as an Integer; with it
# the store aborts and names the slot. Not a snapshot test -- the Makefile runs
# it and asserts the abort.
# spinel: rbs-seed-check
class Bad
  def initialize
    @v = nil
  end

  def v=(x)
    @v = x
  end

  def v
    @v
  end
end

vals = [1, "two"]
b = Bad.new
b.v = vals[1]
p b.v
