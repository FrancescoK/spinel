# String#* copies the unit, then doubles what it has filled: every count
# around a power of two, a unit of several bytes, NUL bytes, a multibyte
# unit and a binary one keep their bytes, length and encoding.
def check(u, n)
  s = u * n
  ok = s.bytesize == u.bytesize * n
  i = 0
  while ok && i < n
    ok = s.byteslice(i * u.bytesize, u.bytesize) == u
    i += 1
  end
  [n, s.bytesize, s.length, s.encoding.to_s, ok]
end

[1, 2, 3, 4, 5, 7, 8, 9, 15, 16, 17, 1023, 1024, 1025].each do |n|
  p check("a", n)
  p check("xyz", n)
end
p check("a\0b", 6)
p check("été", 5)
p check("\xff\x00".b, 9)
p check("ab", 0)
p check("", 7)

big = "\0".b * 20_000_000
p [big.bytesize, big.getbyte(0), big.getbyte(19_999_999), big.encoding.to_s, big.count("\0")]
w = "0123456789" * 100_003
p [w.bytesize, w[0, 12], w[-12, 12], w.count("7")]

mixed = ["ab", 1]
p mixed[0] * 5
begin
  "ab" * -1
rescue ArgumentError => e
  p e.message
end
