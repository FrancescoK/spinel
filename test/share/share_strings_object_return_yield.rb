# spinel: gc-minor
# Yielding methods inline into a demanded handle slot. Fresh block results
# and reads of a String both reach mutable container elements with sharing.
class YieldElement
  def initialize(value) = @value = value
  def get(k) = k == 0 ? yield(@value) : @value + "c"
  def only = yield(@value)
end
class YieldElementChild < YieldElement
end

a = YieldElement.new("s".dup)
arr = [a.get(1) { |s| s }, a.get(0) { |s| s + "b" }]
arr[0] << "#"
arr[1] << "!"
p arr

b = YieldElementChild.new("s".dup)
second = [b.get(1) { |s| s }, b.get(0) { |s| s }]
second[0] << "#"
second[1] << "!"
p second

c = YieldElement.new("s\0b".dup)
h = { source: c.only { |s| s }, fresh: c.only { |s| s + "c" } }
h[:source] << "#"
h[:fresh] << "long" * 50
p h[:source], h[:fresh].size
