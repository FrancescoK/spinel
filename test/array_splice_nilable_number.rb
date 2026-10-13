# A slice store whose value is an Integer or Float that may be nil: CRuby
# splices nil in as an element (a[0..0] = nil gives [nil, 2, 3]), while
# Spinel unwrapped the value and raised TypeError.
def run(nv)
  a = [1, 2, 3]
  n = nv > 0 ? nv : nil
  a[0..0] = n
  p a
  r = 1..1
  p(a[r] = n)
  p a
  f = [1.5, 2.5]
  fl = nv > 0 ? nv * 0.5 : nil
  f[0, 1] = fl
  p f

  i = 1
  i = 0..0 if nv.zero?
  b = [1, 2, 3]
  b[i] = n
  p b
  b[i] = nil
  p b
end
run(0)
run(4)
