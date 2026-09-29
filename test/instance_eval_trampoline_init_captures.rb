# A block handed through new to an initialize that is only instance_eval(&)
# writes the enclosing locals

class Br
  def initialize(x) = @x = x
end
class Ev
  attr_reader :log
  def initialize = @log = []
  def transition(x) = (log << b = Br.new(x); b)
  def context(&) = instance_eval(&)
end
class Machine
  def initialize(&) = instance_eval(&)
  def event(&block)
    e = Ev.new
    e.context(&block)
    e
  end
end
m = nil
n = 0
Machine.new { m = event { transition :idling }; n += 1 }
p [m.log.size, n]
