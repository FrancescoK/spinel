# A local written from a read of another local takes the type that local
# ends up with, also when the write that widens it comes later in the
# program: a later statement of a loop body, or a multiple assignment's
# target (`a, *b = t`). The slot kept the narrower type the read saw first,
# so an Integer slot read a String's box as 0, and a String Array slot read
# a String's (a crash).

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
