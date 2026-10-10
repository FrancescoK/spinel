# A module method that an include copied into a class never runs as itself;
# the copy does, with the class's ivars. The original reads ivars nothing
# writes, so its `@bus.output(port, value)` had an untyped receiver and
# untyped arguments, and it boxed the parameters of every `output` in the
# program: the one the copy calls, and an unrelated one called only with
# Integers.
class Seq
  def output(col, shift) = (col * 8) + shift
end

class Port
  def output(port, value) = port + value
end

module BusCycles
  def output(port, value) = @bus.output(port, value)
end

class Cpu
  include BusCycles

  def initialize(bus)
    @bus = bus
  end
end

s = Seq.new
t = 0
1000.times { |i| t += s.output(i, 3) }
p t
p Cpu.new(Port.new).output(1, 2)
