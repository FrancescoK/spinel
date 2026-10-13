# spinel: reject-subclass: the name of a Struct.new or Data.define class read in its own block
# Kernel.puts(self) prints self as a bare puts does: refused in the block, where
# CRuby has not named the class yet.
Point = Struct.new(:x) do
  Kernel.puts(self)
end
p Point.new(1)
