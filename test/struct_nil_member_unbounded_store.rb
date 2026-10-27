# A store through a box whose classes are unknown (`vars[name] = Info.new`
# on a Hash Marshal handed back) does not type a Struct's nil member as the
# stored object: the member's String writes, also through a box, keep an
# arm for each Struct with the member (#10346).
Func = Struct.new(:name, :mod)
Decl = Struct.new(:kind, :mod)
Info = Struct.new(:type, :line)

def deep(x) = Marshal.load(Marshal.dump(x))

vars = deep({})
name = ARGV.empty? ? "x" : "y"
vars[name] = Info.new(1, 2)
items = [deep(Func.new("f", nil)), deep(Decl.new("t", nil))]
items.each { |n| n.mod = "lib" }
p items.map(&:mod)
p vars[name].type
