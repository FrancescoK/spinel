# A literal right side shorter than the targets leaves nil in every target
# past its elements, whatever the target is: an instance, global or class
# variable, a constant, an attribute or an index, and a target after the
# splat. A slot typed elsewhere as a Float or an Integer still reads nil.
class Holder
  def initialize
    @n = 0
    @f = 1.5
  end

  def fill
    @a, @n, @f = [1]
    p @a, @n, @f
  end
end
Holder.new.fill

$g = 3
$h, $g = [4]
p $h, $g

class Counter
  @@p = 1
  @@q, @@p = [2]
  p @@q, @@p
end

class Box
  attr_accessor :x, :y
end
bx = Box.new
bx.x = 5
bx.y, bx.x = [6]
p bx.y, bx.x

arr = [1, 2, 3]
arr[0], arr[1] = [9]
p arr

h = { a: 1 }
h[:a], h[:b] = [7]
p h

A, *R, B = [1]
p A, R, B

C, D = [2]
p C, D
