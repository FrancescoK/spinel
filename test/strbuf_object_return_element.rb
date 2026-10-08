# spinel: share
# spinel: gc-minor
# A concrete method still returns String bytes when a container demands
# mutable elements. Exercise the copy and shared-return routes without
# observing the source String through another name after mutation.
class ElementReturn
  attr_reader :calls
  def initialize(value)
    @value = value
    @calls = 0
  end
  def fresh = @value + "c"
  def get(k)
    @calls += 1
    k == 0 ? @value : fresh
  end
  def maybe(k)
    @calls += 1
    return @value if k == 0
    return fresh if k == 1
    @value.size
    nil
  end
end
class ElementReturnChild < ElementReturn
end

a = ElementReturn.new("s".dup)
arr = [a.get(1), a.get(0)]
arr[0] << "#"
arr[1] << "!"
p arr, a.calls

hobj = ElementReturnChild.new("s\0b".dup)
h = {}
h[:source] = hobj.maybe(0)
h[:fresh] = hobj.maybe(1)
h[:missing] = hobj.maybe(2)
h[:fresh] << "long" * 50
h[:source] << "!"
p h[:source], h[:fresh].size, h[:missing], hobj.calls
