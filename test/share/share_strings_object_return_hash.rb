# spinel: gc-minor
# Flag-only: Hash values take the same return pickup, including nil after
# another handle read, inherited methods, binary bytes and plain readers.
class ReturnHash
  attr_reader :value
  def initialize(value) = @value = value
  def fresh = @value + "c"
  def get(k)
    return @value if k == 0
    return fresh if k == 1
    @value.size
    nil
  end
end
class ReturnHashChild < ReturnHash
end
src = "s\0b".dup
a = ReturnHashChild.new(src)
h = {}
h[:fresh] = a.get(1)
h[:shared] = a.get(0)
h[:missing] = a.get(2)
h[:fresh] << "#"
h[:shared] << "!"
p h, src
readers = [a.value]
readers[0] << "?"
p readers, src
