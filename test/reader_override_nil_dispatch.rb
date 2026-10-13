# An attr reader that a subclass overrides is read through a switch on the
# runtime class; that read can be nil, from the field or from an override.

class A
  attr_reader :index
  def initialize(i) = @index = i
  def x = index * 2
  def xs = self.index * 2
  def y = 0x27 + index
end
class B < A
  def index = 10
end
puts A.new(3).x
puts B.new(nil).x
puts B.new(nil).xs
puts A.new(3).y
puts B.new(3).y
begin
  A.new(nil).y
rescue TypeError => e
  puts e.class
end

class C
  attr_reader :n
  def initialize(i) = @n = i
  def z = n + 1
  def zs = self.n + 1
  def show = n.inspect
end
class D < C
  def n = nil
end
class E < C
  def n = @n > 0 ? @n : nil
end
class F < C
  def n = super + 5
end
[C.new(1), D.new(1), E.new(2), E.new(0), F.new(1)].each do |o|
  begin
    puts o.z
  rescue NoMethodError => e
    puts e.class
  end
  begin
    puts o.zs
  rescue NoMethodError => e
    puts e.class
  end
  puts o.show
end
