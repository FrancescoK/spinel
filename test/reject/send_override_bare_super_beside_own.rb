# spinel: reject-send-super
# A send whose whole body is `super` answers what Object#send does, and is
# compiled as such only while the program has no other send of its own: here
# Runner's own send makes a send on a receiver known only at run time
# dispatch over the program's send methods, Plain's among them, and Plain's
# super would need Object#send behind it. Refused at this line.
class Plain
  def send(...) = super
  def size = 3
end

class Runner
  def initialize = @queue = []
  def send(message) = @queue << message
end

x = ARGV.empty? ? Plain.new : Runner.new
p x.send(:size)
