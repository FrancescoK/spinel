# A Hash passed positionally to a proc or lambda is not keywords (Ruby 3+),
# and a keyword hash is not a positional.

pr = proc { |a, k: 1| [a, k] }
h = {k: 3}
p pr.call(5, {k: 2})
p pr.call(5, k: 2)
p pr.call(5, h)
p pr.call(5, **h)
p pr.call(5, **{})
p pr.(5, {k: 2})
p pr[5, {k: 2}]
p pr.call(*[5, {k: 2}])
p pr.call(*[5], **h)
p pr.call(k: 2)
p((pr.call(x: 2) rescue $!.message))

l = ->(a, k: 1) { [a, k] }
p((l.call(5, {k: 2}) rescue $!.message))
p l.call(5, k: 2)
p l.call(5, **h)
p((l.call(5, 6) rescue $!.message))
p((l.call(k: 2) rescue $!.message))

l2 = ->(a, b = 0, k: 1) { [a, b, k] }
p l2.call(5, {k: 2})
p l2.call(5, k: 2)

pr2 = proc { |a, b, k: 1| [a, b, k] }
p pr2.call(5, {k: 2})
p pr2.call(5, k: 2)
p pr2.call([1, 2], k: 3)
p pr2.call([1, {k: 2}])

pr3 = proc { |a, *r, z, k: 1| [a, r, z, k] }
p pr3.call(5, 6, k: 2)
p pr3.call(5, 6, {k: 2})

pkr = proc { |a, b = 7, **kw| [a, b, kw] }
p pkr.call(5, {k: 2})
p pkr.call(5, k: 2)

kr = proc { |a, k:| [a, k] }
p kr.call(5, k: 3)
p((kr.call(5, {k: 3}) rescue $!.message))

def y = yield(5, {k: 2})
p(y { |a, k: 1| [a, k] })
def fw(&b) = yield(5, {k: 2})
p fw(&pr)
def fw2(&b) = b.call(5, {k: 2})
p fw2(&pr)
def fw3 = yield(5, k: 2)
p fw3(&pr)
def rec(n, &b)
  return b.call(n, {k: 2}) if n == 0
  rec(n - 1, &b)
end
p(rec(3) { |a, k: 1| [a, k] })

p [[1, {k: 2}]].map { |a, k: 1| [a, k] }
p [{k: 5}].map(&pr)

class Holder
  def initialize(&b) = @b = b
  def pos = @b.call(5, {k: 2})
  def kw = @b.call(5, k: 2)
end
w = Holder.new { |a, k: 1| [a, k] }
p w.pos
p w.kw

boxed = [pr, 1]
p boxed[0].call(5, {k: 2})
p boxed[0].call(5, h)
p boxed[0].call(5, k: 2)
p boxed[0].call(*[5, h])
p boxed[0].call(5, **h)

f = pr >> proc { |x| x }
p f.call(5, k: 2)
p f.call(5, {k: 2})
