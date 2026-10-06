# Integer slots that accept nil in CRuby, fed a boxed nil. Array#fill's
# length read it as 0 and filled nothing, where a nil length is "to the
# end". The include? needle and a `when lo..x` bound already took the nil
# as nil (the needle's poly arm, the Range literal's endpoint); they stay
# here beside it.

src = [1, nil, "s", 1.5]
x = src[1]
p [0, 1].include?(x)
p [0.0, 1.5].include?(x)
p [0, 1].include?(src[0])
p [0.0, 1.5].include?(src[3])

a = [1, 2, 3, 4]
p a.fill(9, 1, x)
b = [1, 2, 3, 4]
p b.fill(8, x, 2)
c = [1, 2, 3, 4]
p c.fill(7, 1, src[0])

def where(v, lo, hi)
  case v
  when lo..hi then :in
  else :out
  end
end
p where(50, src[0], x)
p where(-50, x, src[0])
p where(5, src[0], 3)
p where(0, src[0], 3)
