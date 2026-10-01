# Without `require "socket"`, a class of the program's own named Socket is
# a plain class, not the builtin's reopening.
class Socket
  def initialize(h) = @h = h
  def h = @h
end
module Net
  class Socket
    def x = "x"
  end
end
p Socket.new(3).h, Net::Socket.new.x
