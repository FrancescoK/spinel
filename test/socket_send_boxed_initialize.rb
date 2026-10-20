# A send whose literal name is initialize or initialize_copy, on a value
# held boxed beside a socket, runs that method of the value's class, as
# Object#send does. The socket write's dispatch left the two names out of
# its arms, so the call raised NoMethodError naming send.
require "socket"

class Pier
  def initialize(berth = 0, name = "Ttukseom", gate = 1)
    @berth = berth
    @name = name
    @gate = gate
  end

  def initialize_copy(gate)
    @gate = gate
  end

  def to_s = "#{@name} pier #{@berth}, gate #{@gate}"
end

u = UDPSocket.new
piers = [u, Pier.new]
pier = piers[1]
pier.send("initialize", 3)
puts pier
pier.send("initialize", 5, "Jamsil", 2)
puts pier
pier.send("initialize_copy", 8)
puts pier
[u, Pier.new(1, "Mangwon")].each do |x|
  next if x.is_a?(UDPSocket)
  x.send("initialize", 4, "Yeouido", 9)
  puts x
end
u.close
