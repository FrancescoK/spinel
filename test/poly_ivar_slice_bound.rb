# A slice replacement can introduce a new receiver class.
class A; end
class B; end
xs = [A.new, 0]
xs[0, 1] = [B.new]
o = xs[0]
o.instance_variable_set(:@z, 7)
p o.instance_variable_get(:@z)

ys = [A.new, 0]
ys[0..0] = [B.new]
r = ys[0]
r.instance_variable_set(:@range_z, 8)
p r.instance_variable_get(:@range_z)
