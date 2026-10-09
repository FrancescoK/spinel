# spinel: gc-minor
# Fresh handles keep their bytes and flags through inline growth and collection.
class FreshBox
  attr_reader :value
  def initialize(value)
    @value = value
  end
  def grow
    @value << ("x" * 200)
  end
  def replace(value)
    @value.replace(value)
  end
end
def fresh_text = "owned".dup
def maybe_fresh(flag) = flag ? "fresh".dup : nil
def from_default(value = "default".dup)
  box = FreshBox.new(value)
  box.grow
  p box.value.length
end
def consume(value)
  box = FreshBox.new(value)
  box.grow
  p box.value.length
end
consume(fresh_text)
from_default
small = FreshBox.new("a\0b".dup)
p small.value.bytes, small.value.frozen?
small.grow
p small.value.bytesize
small.replace("short")
p small.value
large = FreshBox.new("z" * 100)
large.grow
p large.value.length
[55, 56].each do |size|
  box = FreshBox.new("b" * size)
  p box.value.bytesize
  box.grow
  p box.value.bytesize
end
frozen = FreshBox.new("frozen")
p frozen.value.frozen?
begin
  frozen.grow
rescue FrozenError
  puts "frozen"
end
nullable = FreshBox.new(maybe_fresh(false))
p nullable.value
100.times do |i|
  box = FreshBox.new(i.to_s)
  box.grow
  raise "lost bytes" unless box.value.length == i.to_s.length + 200
end
puts "loop ok"
