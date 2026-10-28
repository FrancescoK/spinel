# Kernel#select asks each IO-like for to_io
class W
  def initialize(io) = @io = io
  def to_io = @io
end
r, w = IO.pipe
w.write("hi")
rs, = select([W.new(r)], nil, nil, 1)
puts rs.size
class Poller2
  def wait(ios) = select(ios, nil, nil, 1)
end
r2, w2 = IO.pipe
w2.write("hi")
rs2, = Poller2.new.wait([W.new(r2)])
puts rs2.size
