# A method forwarding its block to a File's each / each_line, reached through
# a poly receiver guarded by respond_to?: the respond_to? probe is not a call
# made without a block, so the forward stays a plain loop (#8721).
class Widget
  def initialize(io) = @io = io
  def each(&block) = @io.each(&block)
  def each_line(&block) = @io.each_line(&block)
end

class Wrapped
  def initialize(io) = @io = io
  def each(*args, **opts, &block) = @io.each(*args, **opts, &block)
end

path = "/tmp/sp_io_each_forward_poly_#{Process.pid}.txt"
File.write(path, "a\nb\n")
w = rand < 2 ? Widget.new(File.open(path)) : 4
w.each { |a| p a } if w.respond_to?(:each)
w2 = rand < 2 ? Widget.new(File.open(path)) : 4
w2.each_line { |a| p a.chomp } if w2.respond_to?(:each_line)
w3 = rand < 2 ? Wrapped.new(File.open(path)) : 4
w3.each { |a| p a } if w3.respond_to?(:each)
File.delete(path)
