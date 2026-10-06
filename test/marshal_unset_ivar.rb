# Marshal.dump leaves out an ivar nothing has set yet, as CRuby does: an
# attr_accessor's ivar before its first write, of any type. Marshal.load of
# such a dump answers the same instance_variables.
# Spinel wrote every ivar of the class's layout, an unset one as nil.
class K
  attr_accessor :n, :m
end
k = K.new
p Marshal.dump(k)
k.n = 2
p Marshal.dump(k)
k.m = "s"
p Marshal.dump(k)
p Marshal.load(Marshal.dump(K.new)).instance_variables

class Box
  attr_accessor :items, :count, :rate
end
b = Box.new
p Marshal.dump(b)
b.items = [1]
b.count = 4
b.rate = 1.5
p Marshal.load(Marshal.dump(b)).instance_variables, Marshal.load(Marshal.dump(b)).items
