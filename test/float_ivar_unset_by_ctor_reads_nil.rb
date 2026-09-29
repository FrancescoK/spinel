# A Float ivar no constructor assigns is nil until a method writes it.

class Box
  def set(x) = @v = x
  def report
    p [@v.nil?, @v, @v.to_s, @v == nil]
    puts(@v ? "t" : "f")
    puts "unset" if @v.nil?
    x = @v
    p x
  end
end
b = Box.new
b.report
b.set(1.5)
b.report

# `||=` on the unset slot runs its right-hand side.
class Acc
  def add(x) = (@sum ||= 1.5; @sum += x)
  def sum = @sum
end
a = Acc.new
p a.sum
a.add(2.0)
p a.sum

# Slots a constructor, or a helper it calls, assigns read their value.
class Lazy
  def initialize = setup
  def setup = (@scale = 2.0)
  def apply(x) = x * @scale
end
p Lazy.new.apply(3.0)

class Vec
  def initialize(x, y) = (@x = x; @y = y)
  def len = Math.sqrt(@x * @x + @y * @y)
end
p Vec.new(3.0, 4.0).len

class Temp
  attr_reader :c
  def set(v) = @c = v
  def report = (x = @c; p x; p [@c]; p @c.to_s)
end
t = Temp.new
p t.c
t.report
t.set(21.5)
p t.c
t.report
