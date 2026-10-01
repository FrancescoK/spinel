# CRuby spreads each tuple of combination, permutation and their repeated
# forms across a block taking two or more parameters (m is 3, n is 1). The
# emitters bind the first parameter only, and answered m as the whole tuple
# and n as nil; the block is refused at this line instead.
[3, 1].combination(2) { |m, n| p [m, n] }
