# `a[i] op= <Integer>` on a Float Array stores a Float and keeps the array a
# Float Array (test/infer/index_op_write_int_operand_float_elem.rb pins the
# type). The values must be CRuby's on the unboxed path too: Float#% floors
# toward the divisor's sign, a Float divided by Integer 0 is Infinity, and a
# negative Integer power of a Float is a Float.
a = Array.new(6, -1.5)
a[0] %= 4
a[1] /= 0
a[2] **= -2
a[3] -= 3
a[4] *= -2
a[5] += 1
p a

class OpwHolder
  def initialize
    @v = Array.new(3, 7.0)
  end

  def run(d)
    @v[0] /= d
    @v[1] %= -d
    @v[2] **= d
    @v
  end
end
p OpwHolder.new.run(2)

h = { "x" => 2.0 }
h["x"] /= 4
p h
