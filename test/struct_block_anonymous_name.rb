# A Struct.new or Data.define block a constant holds runs with its class
# anonymous: the constant names it only once the block has run, so self's
# name is nil there and self prints as #<Class:0x...>, as do its instances.
ANON = /\A#<Class:0x\h+>\z/

Point = Struct.new(:x, :y) do
  p name
  p self.to_s.match?(ANON), inspect.match?(ANON), "#{self}".match?(ANON)
  p new(1, 2)
  p new(1, 2).to_s
  $kept = self
  def show = "#{self.class.name}(#{x}, #{y})"
end
p Point.name, Point, $kept, $kept.equal?(Point)
p Point.new(3, 4), Point.new(3, 4).show

Pair = Data.define(:a) do
  p name, to_s.match?(ANON)
  p new(a: 1)
end
p Pair, Pair.new(a: 2)

# Kernel.puts(self) prints self as a bare puts does
class Logger
  def puts(line) = line
end
Note = Struct.new(:x) do
  out = String.new
  out << Kernel.format("%s", self)
  p out.match?(ANON)
end
p Note

# a member that holds its own struct, shown inside the block
Node = Struct.new(:nxt) do
  n = new(nil)
  n.nxt = n
  p n.inspect.match?(/\A#<struct nxt=#<struct #<Class:0x\h+>:\.\.\.>>\z/)
end
p Node.new(nil)
