# `recv&.attr = value` on a nil receiver does nothing: an attr_writer's
# store was inlined as a field write on the receiver with no nil test, and
# the program crashed where CRuby moves on. A `def x=` writer kept the test.
class Trap
  attr_accessor :layout
  def initialize = @layout = 1
  def mode=(m)
    @mode = m
  end
end

class Machine
  def initialize = @trap = nil
  def install = @trap = Trap.new
  def trap_layout = @trap&.layout
  def bump = @trap&.layout += 1

  def changed(layout)
    @trap&.layout = layout
    @trap&.mode = layout
    puts "changed #{layout}"
  end
end

machine = Machine.new
machine.changed(2)
p machine.bump
p machine.trap_layout
machine.install
machine.changed(3)
p machine.bump
p machine.trap_layout

def set(t, v) = (t&.layout = v)
p set(nil, 5)
p set(Trap.new, 6)
x = nil
x&.layout += 1
p x
