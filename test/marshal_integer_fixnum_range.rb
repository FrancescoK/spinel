# spinel: int64
# spinel: gc-stress
# Marshal.dump writes an Integer as a Fixnum record only while it fits the
# 31-bit marshal Fixnum (-2**30 ... 2**30 - 1) and as a Bignum record past it,
# as CRuby does; Marshal.load reads a Bignum record whose value fits an
# Integer back as that Integer. The Bignum record takes a link id, so a String
# written after it links to the right object.
[-2**30 - 1, -2**30, -1, 0, 2**30 - 1, 2**30, 2**31 - 1, 2**31, -2**31, 65535, 65536, 2**32,
 2**40, -2**40, 2**48 + 5, -2**48 - 5, 2**62, -2**62, 2**63 - 1, -2**63].each do |n|
  d = Marshal.dump(n)
  x = Marshal.load(d)
  p d, x, x == n, x.class
end
s = "s"
p Marshal.dump([2**40, s, 2**41, s, 2**40])
y = Marshal.load(Marshal.dump([2**40, s, 2**41, s, 2**40]))
p y, y[1].equal?(y[3])
# Ranges with such ends, dumped by Spinel and written by CRuby
[1..2**40, -2**31..0, -2**62...2**62, 2**31..].each do |r|
  d = Marshal.dump(r)
  x = Marshal.load(d)
  p d, x, x == r
end
p Marshal.load("\x04\bo:\nRange\b:\texclF:\nbegini\x06:\bendl+\b\x00\x00\x00\x00\x00\x01".b)
p Marshal.load("\x04\bo:\nRange\b:\texclF:\nbeginl-\a\x00\x00\x00\x80:\bendi\x00".b)
p Marshal.load("\x04\bl+\n\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00".b)
