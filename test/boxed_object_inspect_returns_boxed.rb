# p on a boxed object whose #inspect answers a String through a value of
# no single type (a method that may also answer nil or a number): the
# object's own #inspect still renders it, not the default ivar walk
class D
  def initialize(n) = @n = n
  def fmt(f) = f ? "D(#{@n})" : @n
  def inspect = fmt(true)
end
class E
  def initialize(n) = @n = n
end
def pick(i) = i == 0 ? D.new(1) : (i == 1 ? E.new(2) : nil)
p pick(0)
p [pick(0), 3]
p({ k: pick(0) })
puts pick(0).inspect
p D.new(4).fmt(false)
class L
  def initialize(s) = @s = s
  def render(f) = f ? "<#{@s}>" : 0
  def to_s = render(true)
end
def pl(i) = i == 0 ? L.new("x") : 5
puts pl(0)
puts "label #{pl(0)}"
