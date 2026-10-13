# spinel: reject-subclass: the name of a Struct.new or Data.define class read in its own block
# Point is named when the constant is written, after the block has run: in
# the block CRuby prints `#<Class:0x...>` for self and nil for self.name, where
# the class here already has its name. Refused rather than answered "Point".
Point = Struct.new(:x) do
  puts "building #{self}"
end
p Point.new(1)
