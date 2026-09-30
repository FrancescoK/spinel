# The run-time "may hold nil" flag on an Integer or Float array is set by the
# cold gap fills and conversions, never by a store of a scalar: a loop writing
# numbers through `a[i] = v` or `<<`, copying elements (`c << a[k]`) or an
# ivar (`out << @v`), keeps the plain store. A whole-array read of an unmarked
# array asks the flag (sp_*Array_nil_*_ck); one analyze marked (a Hash read
# that can miss is stored into it) scans, as it always did.
class Pix
  def initialize = (@v = 7)
  def fill(out) = 4.times { out << @v }
end
a = Array.new(8, 0)
i = 0
while i < 8
  a[i] = i * 2
  i += 1
end
b = []
8.times { |k| b << k }
f = [0.5] * 4
4.times { |k| f[k] = k * 0.5 }
c = [0]
8.times { |k| c << a[k] }
q = [1]
q << b.pop
Pix.new.fill(c)
h = {1 => 2}
m = [3]
m[ARGV.size] = h[ARGV.size + 5]
p a.sum, b.max, f.sum, a.sort.first, c.sum, q.size, (m.sum rescue -1)
