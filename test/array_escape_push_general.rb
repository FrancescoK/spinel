# An Array a push reaches through a path element-type inference does not
# follow takes the pushed element as CRuby does: the Arrays that path can
# answer become general Arrays (#10058).
class Box
  L = [+"s"]
  def initialize = @list = [+"s"]
  def show = p(@list)
  def add_const = (self.class::L << 1)
end
b = Box.new
b.instance_variable_get(:@list) << 1
b.show
c = Box.new
c.instance_exec { @list } << :k
c.show
d = Box.new
d.send(:instance_variable_get, :@list) << 2.5
d.show
Box.new.add_const
p Box::L

def mk(s) = [s]
mk(+"s") << 1
x = mk(+"t")
x << :y
p mk(+"u"), x

M = [+"m"]
nm = "M"
Object.const_get(nm) << 3
p M
