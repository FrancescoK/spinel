# A class body's locals take a name private to the body; a program may spell
# a local of its own like the names made for that, and it is still its own.
class K
  a = 1
  a__cbp1 = 10
  [1, 2].each { |i| t__cbp1 = i * 2; a += t__cbp1; a__cbp1 += i }
  puts a, a__cbp1
end

module M
  n = 5
  n__cbp1 = 7
  3.times { |i| n += i; n__cbp1 -= i }
  puts n, n__cbp1
end

x = 3
x__cbp1 = 4
puts x, x__cbp1
