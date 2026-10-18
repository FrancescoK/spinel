# A constant Array of a known length that a multiple assignment takes apart
# through an `unless` (or an `elsif` ladder, or an arm of several statements)
# is still that constant: its reads at an index inside its length need no
# range test and one outside it is nil. The answers are CRuby's whichever
# shape the assignment is written in.
LUT = [4, 8, 16]
LUT2 = [1, 2, 3]
LUT3 = [5, 6, 7]

n = ARGV.size

a, b = unless n > 0 then LUT else LUT2 end
p [a, b]

c, d = if n > 1 then LUT elsif n > 0 then LUT2 else LUT3 end
p [c, d]

e, f = if n > 0 then LUT else (n += 1; LUT2) end
p [e, f]

def at(i) = LUT[i & 3]

p LUT[0], LUT[1], LUT[2], LUT[-1], LUT[5]
p at(0), at(2), at(3)
p LUT2[1], LUT3[2], LUT3[3]
p LUT.sum, LUT2.sum, LUT3.sum
