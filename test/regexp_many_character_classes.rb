# A pattern may hold more than 256 character classes: the table grows to what
# the pattern needs. Built at run time and as a literal, case-folded too,
# each matching as CRuby's does.

alts = (0...400).map { |i| "[#{[0x4E00 + i].pack("U")}#{[0x3041 + i % 80].pack("U")}]q" }
re = Regexp.new(alts.join("|"))
s = "a#{[0x4E00 + 399].pack("U")}q b#{[0x4E00 + 7].pack("U")}q cぁq"
p s.scan(re)
p "nothing" =~ re

ci = Regexp.new((0...300).map { |i| "[#{[0x100 + i * 2].pack("U")}]z" }.join("|"), Regexp::IGNORECASE)
p "xāZ yɘz".scan(ci)

lit = /[a1][b2][c3][d4][e5][f6][g7][h8][i9][j0]|[k1][l2][m3][n4][o5][p6][q7][r8][s9][t0]/
p "a1b2c3d4e5f6g7h8i9j0 k1".scan(lit)
