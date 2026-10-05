# An Array fetch block can return a receiver outside the array.
class A; end
class B; end
o = [A.new, 0].fetch(99) { B.new }
o.instance_variable_set(:@z, 7)
p o.instance_variable_get(:@z)

other = [A.new, 0].fetch(99, B.new)
other.instance_variable_set(:@default_z, 9)
p other.instance_variable_get(:@default_z)
