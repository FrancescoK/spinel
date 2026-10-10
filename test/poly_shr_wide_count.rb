# spinel: int64 -- 2**40 and counts of 62 and 63 assume a 64-bit Integer
# `>>=` on a boxed Integer: a count of the word size or more leaves only the
# sign (0 or -1), and a negative count shifts left. C leaves a shift by 64 or
# more undefined, and x86 takes the count modulo 64, so 5 >> 64 answered 5.
def shifted(v, n)
  x = v
  x >>= n
  x
end
[5, -5, 2**40, -(2**40), :pad].each do |v|
  next unless v.is_a?(Integer)
  p [62, 63, 64, 65, 1000].map { |n| shifted(v, n) }
  p [-1, -3].map { |n| shifted(v, n) }
end
p shifted(:pad, 1) rescue p $!.class
