# A local written only from an Array read whose boxed index may be a
# Range. narrow_locals_from_arrays typed the local as the element, so the
# subarray a Range reads was taken apart as an Integer: 0, or a Float's
# bits, for [20, 30].
def pick(n) = n > 1 ? (1..2) : 1

[2, 0].each do |n|
  x = [10, 20, 30][pick(n)]
  p x
  y = [1.5, 2.5, 3.5][pick(n)]
  p y
  s = %w[a b c][pick(n)]
  p s
end
