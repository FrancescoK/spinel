# spinel: int64 -- the values are Bignums
# Integer#to_s on a Bignum past the divide-and-conquer threshold answers the
# decimal digits and frees the scratch it converted with. The converter
# (mpz_get_str_dc) and the sparse and all-ones multiplications keep their
# temporaries in a struct and release them in an MRB_ENSURE cleanup block; the
# runtime's stub for that macro never ran the block, so every conversion leaked
# the power-of-five table and the work buffers. The answers were right, so this
# pins the digits and the products; the leak itself shows only under a leak
# checker (`leaks --atExit` on macOS, LeakSanitizer on Linux).
a = 3**5000
b = 7**4000 * 11**3000
c = -(2**9000 + 12345)
d = 10**3000
e = 10**3000 - 1

puts a.to_s.length
puts a.to_s[0, 40]
puts a.to_s[-40, 40]
puts b.to_s.length
puts b.to_s[0, 40]
puts b.to_s[-40, 40]
puts c.to_s.length
puts c.to_s[0, 40]
puts c.to_s[-40, 40]
puts d.to_s.length
puts d.to_s[0, 8]
puts e.to_s.length
puts e.to_s[-8, 8]

sum = 0
200.times do |i|
  sum += (a + i).to_s.length + (c - i).to_s[-3, 3].to_i
end
puts sum

# The two other scratch-holding multiplications: all-ones operands and a sparse
# operand (a few bits set) against a dense one.
ones = 2**8000 - 1
sq = ones * ones
puts sq.bit_length
puts sq % 1000003
puts ((2**8000 - 1) * (2**7000 - 1)) % 1000003
sparse = 2**8000 + 2**4000 + 1
dense = 3**6000
prod = sparse * dense
puts prod.bit_length
puts prod % 1000003
puts (dense * sparse) % 1000003
