# spinel: share
# spinel: gc-minor
# An Array of shared Strings that the program reaches by a name it spells at
# run time (instance_variable_get, class_variable_get, const_get, send of
# those) or inside a block that rebinds self (instance_eval, instance_exec)
# has uses no read of the variable stands for: it keeps the general Array and
# every name sees the one Array.
class Box
  def initialize(l) = @l = l
  def add(s) = @l << s
  def show = p(@l)
end

# a read through the name, the Array changed, an element changed
s = +"s"
b = Box.new([s])
b.add(+"t")
b.instance_variable_get(:@l) << 1
b.instance_variable_get(:@l)[0] << "?"
s << "!"
b.show
p s

# the name sent
s2 = +"s2"
b2 = Box.new([s2])
b2.add(+"t")
b2.send(:instance_variable_get, :@l) << 2
b2.__send__(:instance_variable_get, :@l)[1] << "#"
s2 << "!"
b2.show

# a write through the name
s3 = +"s3"
b3 = Box.new([s3])
b3.add(+"t")
b3.instance_variable_set(:@l, [s3, +"set"])
b3.add(+"u")
s3 << "!"
b3.show

# a block that rebinds self
s4 = +"s4"
b4 = Box.new([s4])
b4.add(+"t")
b4.instance_exec { @l << :sym }
b4.instance_eval { @l << 4 }
s4 << "!"
b4.show

def poke(o) = o.instance_exec { @l << :sym }
s5 = +"s5"
b5 = Box.new([s5])
b5.add(+"t")
poke(b5)
s5 << "!"
b5.show

# a class variable and a constant
class Reg
  def self.setup(s) = @@l = [s]
  def self.add(t) = @@l << t
  def self.show = p(@@l)
end
s6 = +"s6"
Reg.setup(s6)
Reg.add(+"t")
Reg.class_variable_get(:@@l) << 1
s6 << "!"
Reg.show

S7 = +"s7"
L7 = [S7]
def add7(t) = L7 << t
add7(+"t")
Object.const_get(:L7) << 1
x = Object.const_get(:L7)
x << :sym
S7 << "!"
p L7

# the instance variables listed
s8 = +"s8"
b8 = Box.new([s8])
b8.add(+"t")
p b8.instance_variables
s8 << "!"
b8.show

# beside them an Array nothing reaches by a name keeps the handle form
u = +"u"
plain = [u, +"o"]
plain << +"p"
plain.each { |e| e << "." }
u << "?"
p plain, u
