# A class's own `send` is that class's: other receivers' runtime-name sends are
# still Object#send (the bubbletea gem's Runner#send(message) in the same
# program as Thor's and tty-reader's dispatch).
class Runner
  def initialize = @queue = []
  def send(message) = @queue << message
  def flush = send(:queued) && @queue
end

class Greeter
  def hello(name) = "hello #{name}"
  def bye = "bye"
end

r = Runner.new
r.send(:explicit)
p r.flush

g = Greeter.new
%w[hello bye].each do |m|
  args = m == "hello" ? ["ann"] : []
  p g.send(m.to_sym, *args)
  p g.public_send(m, *args)
  p g.__send__(m.to_sym, *args)
end
p 5.send(:+, 3), "ab".send(:upcase)
