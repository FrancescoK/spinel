# A Hash local keyed by an Integer that can be nil, printed by the last
# statement of the program (`p seen`). A read that ends a statement list was
# taken for the answer of a method or block, which hands the Hash on whole, so
# the Hash stayed typed and the nil key was refused at run time (a TypeError)
# where CRuby stores it. The last statement of the program's own body hands
# nothing on.
b = [5, 6][ARGV.size + 7]
seen = {}
seen[3] = 0
seen[b] = 1
p seen
