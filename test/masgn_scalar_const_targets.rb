# A scalar right side gives the first constant target its value and the
# others nil; a constant after the splat takes the scalar only when no
# target comes before the splat.
A, B = 7
p A, B

*r, C = 5.5
p r, C

D, *s, E = "d"
p D, s, E
