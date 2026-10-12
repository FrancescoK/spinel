# A subclass object reached by two paths, written through a setter it
# inherits and read by a method of its own: the subclass's struct repeats
# the parent's fields, and with strict aliasing the C compiler kept the
# stale field across the write through the parent's type (#8673). Every
# class struct may alias another now.
class Status
  def initialize; @value = 0; end
  def value=(v); @value = v; end
end

class CPUStatus < Status
  def zero?; (@value & 2) != 0; end
end

class Bus
  def initialize(status); @status = status; end
  def status; @status; end
end

class CPU
  def initialize
    @status = CPUStatus.new
    @bus = Bus.new(@status)
  end

  def run(v)
    before = @status.zero?
    @bus.status.value = v
    after = @status.zero?
    [before, after]
  end
end

cpu = CPU.new
p cpu.run(2)
p cpu.run(0)
