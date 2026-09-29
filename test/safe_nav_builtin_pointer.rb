class Holder
  def initialize
    @fiber = nil
    @proc = nil
    @error = nil
    @enum = nil
  end

  def fill
    @fiber = Fiber.new { Fiber.yield; 1 }
    @fiber.resume
    @proc = proc { |x| x * 2 }
    @error = RuntimeError.new("boom")
    @enum = [1, 2, 3].each
  end

  def report
    [@fiber&.alive? || false, @proc&.call(21), @error&.message, @enum&.next]
  end
end

h = Holder.new
p h.report
h.fill
p h.report
