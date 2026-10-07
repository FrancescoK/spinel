# A local written from a read of another local takes the type that local
# ends up with, also when the write that widens it comes later in the
# program: a later statement of a loop body, or a multiple assignment's
# target (`a, *b = t`). The slot kept the narrower type the read saw first,
# so an Integer slot read a String's box as 0, and a String Array slot read
# a String's (a crash). The same holds along a chain of such reads, each
# ahead of the write that widens the local it reads (`d = c; c = b;
# b = "xy"` in a loop): the widening reaches every local of the chain.

s = [+"e0", +"e1"]
a, b = s
t = [+"e0", +"e1", +"e2"]
a, *b = t
u = b[0]
u << "!"
p u

b2 = 5
t2 = [+"p", +"q", +"r"]
a2, *b2 = t2
u2 = b2[0]
p u2

b3 = 5
u3 = 0
2.times { u3 = b3[0]; b3 = "xy" }
p u3

b4 = 5
u4 = 0
2.times { u4 = b4; b4 = "xy" }
p u4

b5 = 5
u5 = 0
2.times { u5 = b5.size; b5 = "xyz" }
p u5

b6 = 1.5
u6 = nil
2.times { u6 = b6.to_s; b6 = [7, 8] }
p u6

b7 = [1, 2]
u7 = nil
2.times { u7 = b7.first; b7 = ["s"] }
p u7

b8 = 1
u8 = 0
3.times { |i| u8 = b8; b8 = i.even? ? "e" : 2.5 }
p u8

b9 = 1; c9 = 1; d9 = 0
3.times { d9 = c9; c9 = b9; b9 = "xy" }
p d9

b10 = 1; c10 = 1; d10 = 1; e10 = 1; f10 = 0
i = 0
while i < 5
  f10 = e10.itself; e10 = d10; d10 = c10.itself; c10 = b10; b10 = 2.5
  i += 1
end
p f10

b11 = [1]; c11 = [1]; d11 = [1]; e11 = 0
4.times { e11 = d11[0]; d11 = c11; c11 = b11; b11 = ["s"] }
p e11

b12 = 1; c12 = 1; d12 = 1; e12 = 0
5.times do
  [1].each do
    e12 = d12
    [2].each { d12 = c12 }
  end
  c12 = b12
  b12 = :sym
end
p e12

b13 = 1; c13 = 1; d13 = 1; e13 = 1; f13 = 0
4.times { c13 = b13; f13 = e13; e13 = d13; d13 = c13; b13 = "z" }
p f13

def chain_in_method(t)
  b = 1; c = 1; d = 0
  3.times { d = c; c = b; a, *b = t }
  d
end
p chain_in_method([+"p", +"q", +"r"])
