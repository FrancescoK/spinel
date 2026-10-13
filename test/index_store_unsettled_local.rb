# An Integer-keyed `a[i] = v` into a local whose value is still untyped
# (a parameter's `bytes`) stores into the Array it turns out to be, not an
# Integer-keyed Hash, so `&:sym` and with_index blocks over it take one
# element each.
def ints(s)
  a = s.bytes
  a[3] = 1
  p a.select(&:nil?)
  p a.reject(&:nil?)
  p a.count(&:nil?)
  p a.map(&:to_s)
  p a.select.with_index { |v, i| v.nil? || i == 0 }
  p a.reject.with_index { |v, i| v.nil? }
  p a.filter_map.with_index { |v, i| [v, i] if v.nil? }
  p a.each_with_index.select { |v, i| v.nil? }
  p a.each_with_index.map { |v, i| [v, i] }
  p a.map.with_index { |v, i| [v, i] }
end

def sums(s)
  b = s.bytes
  b[0] = -b[0]
  p b.sum(&:abs)
  p b.map(&:to_s)
end

ints("ab")
sums("ab")
