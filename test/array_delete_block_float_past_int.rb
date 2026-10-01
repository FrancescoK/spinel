# An Integer Array's delete with a block, given a Float from a call, deletes
# the element that Float equals; a Float past the Integer range, or not
# whole, equals none, and the block gets the Float. The range check is
# sp_int's, which is 32 bits on the -m32 and wasm32 builds.
$calls = 0
def num(x)
  $calls += 1
  x
end

a = [1, 2, 3]
p a.delete(num(2.0)) { |v| [:miss, v] }
p a
p a.delete(num(3.0e9)) { |v| [:miss, v] }
p a.delete(num(-3.0e9)) { |v| [:miss, v] }
p a.delete(num(1.0e19)) { |v| [:miss, v] }
p a.delete(num(-1.0e19)) { |v| [:miss, v] }
p a.delete(num(-9.223372036854775808e18)) { |v| [:miss, v] }
p a.delete(num(2147483648.0)) { |v| [:miss, v] }
p a.delete(num(-2147483649.0)) { |v| [:miss, v] }
p a.delete(num(Float::INFINITY)) { |v| [:miss, v] }
p a.delete(num(-3.0)) { |v| [:miss, v] }
p a.delete(num(3.0)) { |v| [:miss, v] }
p a, $calls

b = [nil, 4]
p b.delete(num(-9.223372036854775808e18)) { |v| [:miss, v] }
p b

# -2**63 as a Float is the sentinel's bit pattern as an Integer: it must not
# delete the nil hole that `c[3] = 7` leaves
c = [5, 6]
c[3] = 7
p c.delete(num(-9.223372036854775808e18)) { |v| [:miss, v] }
p c
