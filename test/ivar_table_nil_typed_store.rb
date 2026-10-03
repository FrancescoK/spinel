# A value typed nil through the fixpoint, stored into an ivar table of int
# arrays. The table pass takes a nil for a row, and such a value has its
# boxed type only after the fixpoint, so the pass has to vet the table it
# pinned once more there. Without that an appended nil-only local or
# parameter gave C that does not build (an sp_RbVal handed to
# sp_PtrArray_push), and `h = nil; h ||= []` stored a boxed Array that was
# read back as a bare sp_IntArray * ([0, 0, 0, 0, 0, 0, 0, 0] for []).
class PushLocal
  def initialize
    @t = [[1, 2], [3]]
  end
  def add
    x = nil
    @t << x
    @t.length
  end
  def first(i) = @t[i][0]
end
a = PushLocal.new
p a.add, a.first(0), a.first(1)

class PushParam
  def initialize
    @t = [[4, 5], [6]]
  end
  def add(row)
    @t.push(row)
    @t.length
  end
  def first(i) = @t[i][0]
end
b = PushParam.new
p b.add(nil), b.first(0), b.first(1)

class OrArray
  def initialize
    @t = [[1, 2], [3]]
  end
  def put(i)
    h = nil
    h ||= []
    @t[i] = h
    @t[i]
  end
  def grow(i)
    @t[i] << 5
    @t[i].length
  end
  def len(i) = @t[i].length
  def first(i) = @t[i][0]
end
c = OrArray.new
p c.first(1)
p c.put(0)
p c.grow(0), c.len(0), c.first(0), c.first(1)

class IfArray
  def initialize
    @t = [[7, 8], [9]]
  end
  def put(i, flag)
    h = nil
    h = [] if flag
    @t[i] = h
    @t[i]
  end
  def len(i) = @t[i].length
  def first(i) = @t[i][0]
end
d = IfArray.new
p d.put(0, true)
p d.len(0), d.first(1)
p d.put(1, false)

# a nil-only local stored by index: the table goes boxed, the answers stay
class IndexLocal
  def initialize
    @t = [[1, 2], [3]]
  end
  def clear(i)
    x = nil
    @t[i] = x
    @t[i]
  end
  def first(i) = @t[i][0]
end
e = IndexLocal.new
p e.first(0), e.first(1)
p e.clear(0)
p e.first(1)
