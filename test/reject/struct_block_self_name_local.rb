# spinel: reject-subclass: the name of a Struct.new or Data.define class read in its own block
# A block whose class a local holds does not yet run with the class as self,
# so a read of the class's name there (CRuby: #<Class:0x...>, as the class is
# anonymous) is refused rather than answered for another self.
k = Struct.new(:x) do
  puts "building #{self}"
end
p k.new(1).x
