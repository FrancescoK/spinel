# spinel: int64
# upto on a boxed Bignum with a boxed limit counts through the Bignums,
# with a block and as an Enumerator, where it raised RangeError; a String
# limit is the comparison's ArgumentError.

def poly(x) = [x, "s"][ARGV.size]

n = poly(2**64)
lim = poly(2**64 + 2)
begin
  n.upto(lim) { |i| print i, " " }
  puts
  p n.upto(lim).to_a
  n.upto(poly("c")) { }
rescue => e
  puts "#{e.class}: #{e.message}"
end
m = poly(2**64 - 1)
p m.upto(poly(2**64 + 1)).to_a
r = []
poly(1).upto(poly(3)) { |i| r << i }
p r
