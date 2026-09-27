# A row stored into an ivar table whose type is not known until a later
# round: the value comes through a chain of methods whose return types
# resolve late. The table pass took the untyped value as a row and pinned the
# table to int arrays for good, so when the value turned out boxed it was read
# back as a bare sp_IntArray * ([0, 2, 0, 0, 0, 0, 0, 0]). The table now waits
# until the stored value is typed.
class Chain
  def initialize
    @banks = [[1]]
    @patterns = [[]]
  end
  def bank
    @banks[0] = later
    @banks[0]
  end
  def later
    deeper(helper)
  end
  def deeper(x)
    x
  end
  def helper
    h = @patterns[0]
    h << 1
    h << 2
    h
  end
end
p Chain.new.bank

class Deep
  def initialize
    @banks = [[1]]
    @patterns = [[]]
  end
  def bank
    @banks[0] = a1
    @banks[0]
  end
  def a1; a2; end
  def a2; a3; end
  def a3; a4; end
  def a4
    h = @patterns[0]
    h << 7
    h << 8
    h
  end
end
p Deep.new.bank

class Typed
  def initialize
    @rows = [[1]]
  end
  def fill
    @rows[0] = row
    @rows << []
    @rows[1] << 4
    @rows[0][1] + @rows[1][0]
  end
  def row
    [2, 3]
  end
end
p Typed.new.fill
