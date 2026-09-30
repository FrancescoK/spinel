# spinel: int64
# Float#to_i on a typed Float truncates in-range values inline and sends NaN
# and Infinity to the raising path. Every case here goes through the typed
# conversion: the receiver is a Float local or a Float array element.

def conv(a)
  out = []
  i = 0
  while i < a.length
    out << a[i].to_i
    i += 1
  end
  out
end

# truncation toward zero, both signs, and both zeros
p conv([3.7, -3.7, 0.5, -0.5, 0.0, -0.0, 1.0, -1.0, 2.5, -2.5])

# large magnitudes that still fit
p conv([9.0e18, -9.0e18, 2.0**62, -(2.0**62), 9.223372036854775e18, 4.5e15 + 0.5])

# a bin index computed the way a histogram does it
lo = -1.25
w = 0.5
bins = [-1.25, -1.0, -0.76, 0.0, 0.24, 1.74].map { |x| ((x - lo) / w).to_i }
p bins

# NaN and Infinity raise FloatDomainError
[0.0 / 0.0, 1.0 / 0.0, -1.0 / 0.0].each do |v|
  begin
    v.to_i
    p :no_raise
  rescue FloatDomainError => e
    p e.class
  end
end
