# `op=` on a constant that holds an Array, a Float or a poly value compiles
# (the raw C operator only fit an Integer) and keeps Ruby's results

A = [1]
[2, 3].each { |x| A += [x] }
p A
F = 0.5
i = 0
until i == 3; F += 1; i += 1; end
p F
loop { F *= 2; break if F > 10 }
p F
n = 0
begin
  n += 1
  F -= 1
  raise "r" if n < 3
rescue
  retry
end
p F
class Box
  L = [1]
  L += [2]
  T = 1.0
  T += 1
  def self.l; L; end
  def self.t; T; end
end
p Box.l, Box.t
def bump; $c = ($c || 0) + 1; [$c]; end
A2 = [0]
A2 += bump
A2 += bump
p A2
W = 3
W += 1
p W
P2 = [1, "b"].reverse[0]
begin
  P2 += 1
rescue TypeError
  puts "TypeError"
end
p P2
E = [[1, 2], 3][0]
E += [3]
p E
S = "ab"
S *= 2
p S
