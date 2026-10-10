# spinel: int64
# A boxed value read under an is_a?(Integer) / kind_of?(Integer) guard is a
# Bignum as often as a word, and reads as the Integer it is.
def show(v)
  if v.is_a?(Integer)
    p v
    p v + 1
    p v * 3
    p v.to_s(16)
  else
    p :other
  end
end
[-(2**100), 7, 2**64, :pad, "s"].each { |v| show(v) }

[2**70, -3, :pad].each do |v|
  next unless v.kind_of?(Integer)
  p v - 1
  p v.even?
end

# Integer's own methods take a boxed Bignum argument exactly
big = [2**70, :x][0]
p 6.gcd(big)
p 6.lcm(big)
p 6.gcdlcm(big)
p 6.ceildiv(big)
p (2**80).ceildiv([-(2**70), :x][0])
small = [4, :x][0]
p 6.gcd(small)
p 6.lcm(small)
